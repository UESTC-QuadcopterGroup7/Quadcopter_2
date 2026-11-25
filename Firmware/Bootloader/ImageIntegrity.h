#ifndef IMAGE_INTEGRITY_H
#define IMAGE_INTEGRITY_H

#include <stddef.h>
#include <stdint.h>

#define QBT_TAG_SIZE 32u

uint32_t QBT_Crc32(const uint8_t *data, size_t length);
void QBT_ImageTag(const uint8_t key[QBT_TAG_SIZE], const uint8_t *data, size_t length,
                  uint8_t tag[QBT_TAG_SIZE]);
uint8_t QBT_TagMatches(const uint8_t a[QBT_TAG_SIZE], const uint8_t b[QBT_TAG_SIZE]);

#endif
