#include "ImageIntegrity.h"
#include <string.h>

/* CRC-32/ISO-HDLC, reflected polynomial, initial and final XOR of all ones. */
uint32_t QBT_Crc32(const uint8_t *data, size_t length)
{
    uint32_t crc = 0xffffffffu;

    while (length-- != 0u) {
        uint8_t bit;
        crc ^= *data++;
        for (bit = 0u; bit < 8u; ++bit) {
            crc = (crc >> 1) ^ (0xedb88320u & (0u - (crc & 1u)));
        }
    }
    return ~crc;
}

/* SHA-256 compression and padding per FIPS 180-4. Images fit in one Flash slot. */
typedef struct {
    uint32_t state[8];
    uint32_t length;
    uint8_t block[64];
    uint8_t used;
} Sha256;

static const uint32_t round_constants[64] = {
    0x428a2f98u,0x71374491u,0xb5c0fbcfu,0xe9b5dba5u,0x3956c25bu,0x59f111f1u,0x923f82a4u,0xab1c5ed5u,
    0xd807aa98u,0x12835b01u,0x243185beu,0x550c7dc3u,0x72be5d74u,0x80deb1feu,0x9bdc06a7u,0xc19bf174u,
    0xe49b69c1u,0xefbe4786u,0x0fc19dc6u,0x240ca1ccu,0x2de92c6fu,0x4a7484aau,0x5cb0a9dcu,0x76f988dau,
    0x983e5152u,0xa831c66du,0xb00327c8u,0xbf597fc7u,0xc6e00bf3u,0xd5a79147u,0x06ca6351u,0x14292967u,
    0x27b70a85u,0x2e1b2138u,0x4d2c6dfcu,0x53380d13u,0x650a7354u,0x766a0abbu,0x81c2c92eu,0x92722c85u,
    0xa2bfe8a1u,0xa81a664bu,0xc24b8b70u,0xc76c51a3u,0xd192e819u,0xd6990624u,0xf40e3585u,0x106aa070u,
    0x19a4c116u,0x1e376c08u,0x2748774cu,0x34b0bcb5u,0x391c0cb3u,0x4ed8aa4au,0x5b9cca4fu,0x682e6ff3u,
    0x748f82eeu,0x78a5636fu,0x84c87814u,0x8cc70208u,0x90befffau,0xa4506cebu,0xbef9a3f7u,0xc67178f2u
};

static uint32_t RotateRight(uint32_t x, uint8_t shift)
{
    return (x >> shift) | (x << (32u - shift));
}

static void ShaInit(Sha256 *sha)
{
    static const uint32_t initial[8] = {
        0x6a09e667u, 0xbb67ae85u, 0x3c6ef372u, 0xa54ff53au,
        0x510e527fu, 0x9b05688cu, 0x1f83d9abu, 0x5be0cd19u
    };
    memcpy(sha->state, initial, sizeof(initial));
    sha->length = 0u;
    sha->used = 0u;
}

static void ShaBlock(Sha256 *sha)
{
    uint32_t words[64];
    uint32_t a = sha->state[0], b = sha->state[1], c = sha->state[2], d = sha->state[3];
    uint32_t e = sha->state[4], f = sha->state[5], g = sha->state[6], h = sha->state[7];
    uint8_t i;

    for (i = 0u; i < 16u; ++i) {
        const uint8_t *p = &sha->block[4u * i];
        words[i] = ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) |
                   ((uint32_t)p[2] << 8) | p[3];
    }
    for (i = 16u; i < 64u; ++i) {
        uint32_t x = words[i - 15u], y = words[i - 2u];
        uint32_t s0 = RotateRight(x, 7u) ^ RotateRight(x, 18u) ^ (x >> 3);
        uint32_t s1 = RotateRight(y, 17u) ^ RotateRight(y, 19u) ^ (y >> 10);
        words[i] = words[i - 16u] + s0 + words[i - 7u] + s1;
    }
    for (i = 0u; i < 64u; ++i) {
        uint32_t s0 = RotateRight(a, 2u) ^ RotateRight(a, 13u) ^ RotateRight(a, 22u);
        uint32_t s1 = RotateRight(e, 6u) ^ RotateRight(e, 11u) ^ RotateRight(e, 25u);
        uint32_t choose = (e & f) ^ (~e & g);
        uint32_t majority = (a & b) ^ (a & c) ^ (b & c);
        uint32_t t1 = h + s1 + choose + round_constants[i] + words[i];
        uint32_t t2 = s0 + majority;
        h = g; g = f; f = e; e = d + t1;
        d = c; c = b; b = a; a = t1 + t2;
    }
    sha->state[0] += a; sha->state[1] += b; sha->state[2] += c; sha->state[3] += d;
    sha->state[4] += e; sha->state[5] += f; sha->state[6] += g; sha->state[7] += h;
}

static void ShaWrite(Sha256 *sha, const uint8_t *data, size_t length)
{
    sha->length += (uint32_t)length;
    while (length != 0u) {
        size_t take = sizeof(sha->block) - sha->used;
        if (take > length) take = length;
        memcpy(sha->block + sha->used, data, take);
        data += take;
        length -= take;
        sha->used += (uint8_t)take;
        if (sha->used == sizeof(sha->block)) {
            ShaBlock(sha);
            sha->used = 0u;
        }
    }
}

static void ShaFinish(Sha256 *sha, uint8_t digest[QBT_TAG_SIZE])
{
    uint8_t padding[64] = {0x80u};
    uint8_t size[8] = {0u};
    uint32_t bits = sha->length * 8u;
    uint8_t i;

    for (i = 0u; i < 4u; ++i) size[7u - i] = (uint8_t)(bits >> (8u * i));
    ShaWrite(sha, padding, sha->used < 56u ? 56u - sha->used : 120u - sha->used);
    ShaWrite(sha, size, sizeof(size));
    for (i = 0u; i < QBT_TAG_SIZE; ++i) {
        digest[i] = (uint8_t)(sha->state[i / 4u] >> (24u - (i % 4u) * 8u));
    }
}

void QBT_ImageTag(const uint8_t key[QBT_TAG_SIZE], const uint8_t *data, size_t length,
                  uint8_t tag[QBT_TAG_SIZE])
{
    Sha256 sha;
    uint8_t pad[64];
    uint8_t inner[QBT_TAG_SIZE];
    uint8_t i;

    memset(pad, 0x36, sizeof(pad));
    for (i = 0u; i < QBT_TAG_SIZE; ++i) pad[i] ^= key[i];
    ShaInit(&sha);
    ShaWrite(&sha, pad, sizeof(pad));
    ShaWrite(&sha, data, length);
    ShaFinish(&sha, inner);

    for (i = 0u; i < sizeof(pad); ++i) pad[i] ^= 0x36u ^ 0x5cu;
    ShaInit(&sha);
    ShaWrite(&sha, pad, sizeof(pad));
    ShaWrite(&sha, inner, sizeof(inner));
    ShaFinish(&sha, tag);
}

uint8_t QBT_TagMatches(const uint8_t a[QBT_TAG_SIZE], const uint8_t b[QBT_TAG_SIZE])
{
    uint8_t diff = 0u;
    uint8_t i;
    for (i = 0u; i < QBT_TAG_SIZE; ++i) diff |= a[i] ^ b[i];
    return (uint8_t)(diff == 0u);
}
