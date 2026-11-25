#include "stm32f4xx.h"
#include "BluetoothBoot.h"
#include "ImageIntegrity.h"
#include "BootKey.local.h"
#include <string.h>

#define CPU_HZ          16000000u  /* HSI 默认 SYSCLK，无 APB2 分频。 */
#define SERIAL_BAUD     115200u
#define CHUNK_SIZE      256u
#define IMAGE_MAGIC     0x51424931u
#define FLASH_ERRORS    (FLASH_SR_SOP | FLASH_SR_WRPERR | FLASH_SR_PGAERR | \
                         FLASH_SR_PGPERR | FLASH_SR_PGSERR)

enum { INFO = 1, BEGIN = 2, DATA = 3, FINISH = 4 };
enum { OK = 0, BAD_REQUEST = 1, FLASH_ERROR = 2, BAD_IMAGE = 3 };

typedef struct {
    uint32_t magic;
    uint32_t length;
    uint32_t crc;
    uint8_t tag[QBT_TAG_SIZE];
} ImageFooter;

#define APP_FOOTER     (QBT_STAGE_BASE - sizeof(ImageFooter))
#define STAGE_FOOTER   (QBT_FLASH_END - sizeof(ImageFooter))
#define IMAGE_LIMIT    (APP_FOOTER - QBT_APP_BASE)

static const uint8_t image_key[QBT_TAG_SIZE] = { QBT_IMAGE_KEY };
static ImageFooter pending;
static uint32_t written;
static uint8_t receiving;
static uint8_t packet[3u + 4u + CHUNK_SIZE + 4u]; /* 命令、长度、偏移、数据、CRC32 */

static void SerialInit(void)
{
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    RCC->APB2ENR |= RCC_APB2ENR_USART1EN;
    (void)RCC->APB2ENR;
    GPIOA->AFR[1] = (GPIOA->AFR[1] & ~0xff0u) | 0x770u;
    GPIOA->PUPDR = (GPIOA->PUPDR & ~(3u << 20)) | (1u << 20);
    GPIOA->MODER = (GPIOA->MODER & ~(0xfu << 18)) | (0xau << 18);
    USART1->BRR = (CPU_HZ + SERIAL_BAUD / 2u) / SERIAL_BAUD;
    USART1->CR1 = USART_CR1_UE | USART_CR1_TE | USART_CR1_RE;
}

static uint8_t ReadByte(uint8_t *byte, uint32_t ms)
{
    uint32_t started = DWT->CYCCNT;
    do {
        uint32_t status = USART1->SR;
        if ((status & (USART_SR_ORE | USART_SR_FE | USART_SR_NE)) != 0u) {
            (void)USART1->DR;
        } else if ((status & USART_SR_RXNE) != 0u) {
            *byte = (uint8_t)USART1->DR;
            return 1u;
        }
    } while ((uint32_t)(DWT->CYCCNT - started) < ms * (CPU_HZ / 1000u));
    return 0u;
}

static uint32_t ReadU32(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static void WriteU32(uint8_t *p, uint32_t value)
{
    uint8_t i;
    for (i = 0u; i < 4u; ++i) p[i] = (uint8_t)(value >> (8u * i));
}

static uint8_t ReadPacket(uint16_t *length)
{
    uint8_t byte;
    uint16_t i;

    if (!ReadByte(&byte, 50u) || byte != 'Q' ||
        !ReadByte(&byte, 150u) || byte != 'B') return 0u;
    for (i = 0u; i < 3u; ++i) {
        if (!ReadByte(&packet[i], 150u)) return 0u;
    }
    *length = (uint16_t)(packet[1] | ((uint16_t)packet[2] << 8));
    if (*length > CHUNK_SIZE + 4u) return 0u;
    for (i = 3u; i < *length + 7u; ++i) {
        if (!ReadByte(&packet[i], 150u)) return 0u;
    }
    return (uint8_t)(ReadU32(&packet[3u + *length]) == QBT_Crc32(packet, 3u + *length));
}

static void Reply(uint8_t cmd, uint8_t status)
{
    uint8_t response[15] = {'Q', 'B', (uint8_t)(cmd | 0x80u), 1u, 0u, status};
    uint8_t i;
    if (cmd == INFO && status == OK) {
        response[3] = 6u;
        response[6] = 1u; /* 协议版本 */
        WriteU32(&response[7], (uint32_t)IMAGE_LIMIT);
    } else if (cmd == DATA && status == OK) {
        response[3] = 5u;
        WriteU32(&response[6], ReadU32(packet + 3u));
    }
    i = (uint8_t)(5u + response[3]);
    WriteU32(&response[i], QBT_Crc32(response + 2u, 3u + response[3]));
    for (i = 0u; i < 9u + response[3]; ++i) {
        while ((USART1->SR & USART_SR_TXE) == 0u) {}
        USART1->DR = response[i];
    }
    while ((USART1->SR & USART_SR_TC) == 0u) {}
}

static void FlashUnlock(void)
{
    FLASH->KEYR = 0x45670123u;
    FLASH->KEYR = 0xcdef89abu;
}

static uint8_t FlashErase(uint8_t first, uint8_t last)
{
    uint8_t sector;
    for (sector = first; sector <= last; ++sector) {
        FLASH->SR = FLASH_ERRORS | FLASH_SR_EOP;
        FLASH->CR = FLASH_CR_SER | ((uint32_t)sector << 3); /* x8 */
        FLASH->CR |= FLASH_CR_STRT;
        while ((FLASH->SR & FLASH_SR_BSY) != 0u) {}
        FLASH->CR = 0u;
        if ((FLASH->SR & FLASH_ERRORS) != 0u) return 0u;
    }
    return 1u;
}

static uint8_t FlashWrite(uint32_t address, const uint8_t *source, uint32_t length)
{
    volatile uint8_t *dst = (volatile uint8_t *)address;

    FLASH->SR = FLASH_ERRORS | FLASH_SR_EOP;
    FLASH->CR = FLASH_CR_PG; /* x8，允许尾部不足一个字。 */
    while (length-- != 0u) {
        uint8_t value = *source++;
        if (*dst != value) {
            *dst = value;
            while ((FLASH->SR & FLASH_SR_BSY) != 0u) {}
            if ((FLASH->SR & FLASH_ERRORS) != 0u || *dst != value) {
                FLASH->CR = 0u;
                return 0u;
            }
        }
        ++dst;
    }
    FLASH->CR = 0u;
    return 1u;
}

static uint8_t Commit(uint32_t address, const ImageFooter *footer)
{
    const uint8_t *bytes = (const uint8_t *)footer;
    /* 长度、CRC 和认证标签全部写完后，最后写有效标志。 */
    return FlashWrite(address + 4u, bytes + 4u, sizeof(*footer) - 4u) &&
           FlashWrite(address, bytes, 4u);
}

static uint8_t ValidSize(uint32_t length)
{
    return (uint8_t)(length >= 8u && length <= IMAGE_LIMIT);
}

static uint8_t ValidImage(uint32_t address, const ImageFooter *footer)
{
    const uint8_t *bytes = (const uint8_t *)address;
    uint32_t msp = ReadU32(bytes);
    uint32_t reset = ReadU32(bytes + 4u);
    uint8_t tag[QBT_TAG_SIZE];

    if (footer->magic != IMAGE_MAGIC || !ValidSize(footer->length) ||
        msp <= 0x20000000u || msp > 0x20018000u || (msp & 7u) != 0u ||
        (reset & 1u) == 0u || reset < QBT_APP_BASE + 8u ||
        reset >= QBT_APP_BASE + footer->length ||
        QBT_Crc32(bytes, footer->length) != footer->crc) return 0u;
    QBT_ImageTag(image_key, bytes, footer->length, tag);
    return QBT_TagMatches(tag, footer->tag);
}

static uint8_t ApplyImage(const ImageFooter *stage)
{
    uint8_t ok;
    FlashUnlock();
    ok = FlashErase(1u, 5u) &&
         FlashWrite(QBT_APP_BASE, (const uint8_t *)QBT_STAGE_BASE, stage->length) &&
         ValidImage(QBT_APP_BASE, stage) &&
         Commit(APP_FOOTER, stage);
    FLASH->CR = FLASH_CR_LOCK;
    return ok;
}

static uint8_t Update(uint8_t cmd, const uint8_t *payload, uint16_t length)
{
    uint8_t ok;
    uint32_t offset;
    uint32_t size;

    if (cmd == INFO) return length == 0u ? OK : BAD_REQUEST;
    if (cmd == BEGIN) {
        if (length != 8u + QBT_TAG_SIZE || !ValidSize(ReadU32(payload))) return BAD_REQUEST;
        receiving = 0u;
        /* 已安装的镜像留在原位，所有接收写操作都限定在扇区 6–7。 */
        FlashUnlock();
        ok = FlashErase(6u, 7u);
        FLASH->CR = FLASH_CR_LOCK;
        if (!ok) return FLASH_ERROR;
        pending.magic = IMAGE_MAGIC;
        pending.length = ReadU32(payload);
        pending.crc = ReadU32(payload + 4u);
        memcpy(pending.tag, payload + 8u, sizeof(pending.tag));
        written = 0u;
        receiving = 1u;
        return OK;
    }
    if (!receiving) return BAD_REQUEST;
    if (cmd == DATA) {
        if (length <= 4u) return BAD_REQUEST;
        offset = ReadU32(payload);
        size = length - 4u;
        if (offset > pending.length || size > pending.length - offset) return BAD_REQUEST;
        /* PC 未收到应答时可重发同一块。 */
        if (offset < written && size <= written - offset &&
            memcmp((const void *)(QBT_STAGE_BASE + offset), payload + 4u, size) == 0) return OK;
        if (offset != written) return BAD_REQUEST;
        FlashUnlock();
        ok = FlashWrite(QBT_STAGE_BASE + offset, payload + 4u, size);
        FLASH->CR = FLASH_CR_LOCK;
        if (!ok) return FLASH_ERROR;
        written += size;
        return OK;
    }
    if (cmd != FINISH || length != 0u || written != pending.length) return BAD_REQUEST;
    receiving = 0u;
    if (!ValidImage(QBT_STAGE_BASE, &pending)) return BAD_IMAGE;
    FlashUnlock();
    ok = Commit(STAGE_FOOTER, &pending);
    FLASH->CR = FLASH_CR_LOCK;
    if (!ok) return FLASH_ERROR;
    /* 保存暂存区，安装中途断电时由下一次启动重新安装。 */
    return ApplyImage(&pending) ? OK : FLASH_ERROR;
}

__asm static void JumpToReset(uint32_t msp, uint32_t reset)
{
    MSR MSP, r0
    BX r1
}

static void StartApplication(void)
{
    uint32_t msp = *(const uint32_t *)QBT_APP_BASE;
    uint32_t reset = *(const uint32_t *)(QBT_APP_BASE + 4u);
    RCC->APB2RSTR |= RCC_APB2RSTR_USART1RST;
    RCC->APB2RSTR &= ~RCC_APB2RSTR_USART1RST;
    RCC->AHB1RSTR |= RCC_AHB1RSTR_GPIOARST;
    RCC->AHB1RSTR &= ~RCC_AHB1RSTR_GPIOARST;
    SCB->VTOR = QBT_APP_BASE;
    __DSB();
    __ISB();
    JumpToReset(msp, reset);
}

static uint8_t WaitForWake(void)
{
    uint32_t start = DWT->CYCCNT;
    uint8_t byte;
    uint8_t matched = 0u;
    while ((uint32_t)(DWT->CYCCNT - start) < (CPU_HZ / 1000u) * 1500u) {
        if (ReadByte(&byte, 50u) && QBT_MatchWake(byte, &matched)) return 1u;
    }
    return 0u;
}

int main(void)
{
    const ImageFooter *installed = (const ImageFooter *)APP_FOOTER;
    const ImageFooter *stage = (const ImageFooter *)STAGE_FOOTER;
    uint8_t valid = ValidImage(QBT_APP_BASE, installed);
    uint8_t requested;
    uint32_t activity;

    /* 应用损坏或版本不同且暂存包完整时，继续完成上次安装。 */
    if ((!valid || installed->length != stage->length || installed->crc != stage->crc ||
         !QBT_TagMatches(installed->tag, stage->tag)) && ValidImage(QBT_STAGE_BASE, stage)) {
        valid = ApplyImage(stage);
    }

    QBT_EnableBackupWrite();
    requested = (uint8_t)(RTC->BKP0R == QBT_REQUEST);
    RTC->BKP0R = 0u;
    PWR->CR &= ~PWR_CR_DBP;
    SerialInit();
    if (valid && !requested && !WaitForWake()) StartApplication();

    activity = DWT->CYCCNT;
    for (;;) {
        uint16_t length;
        if (ReadPacket(&length)) {
            uint8_t cmd = packet[0];
            uint8_t status = Update(cmd, packet + 3u, length);
            Reply(cmd, status);
            if (cmd == FINISH) {
                if (status == OK) NVIC_SystemReset();
                valid = ValidImage(QBT_APP_BASE, installed);
            }
            activity = DWT->CYCCNT;
        }
        if (valid && (uint32_t)(DWT->CYCCNT - activity) >= CPU_HZ * 25u) StartApplication();
    }
}
