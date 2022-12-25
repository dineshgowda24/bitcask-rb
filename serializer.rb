require 'zlib'

module Serializer

    # tz, keysz, valuesz
    # 3 - 32 bit unsigned long int with little endian byte order
    # 3 - 32 bit unsigned long int = 12 bytes
    HEADER_FORMAT = "L<L<L<"
    HEADER_SIZE = 12

    # 32 bit unsigned long int
    CRC32_FORMAT = "L"
    CRC32_SIZE = 4

    def serialize(epoc:, key:, value:)
        header = searlize_header(epoc: epoc, keysz: key.length, valuesz: value.length)
        data = key.encode("utf-8") + value.encode("utf-8")

        return CRC32_SIZE + HEADER_SIZE + data.length, crc32(header+data) + header + data
    end

    def deserialize(data)
        raw_data = data[CRC32_SIZE]
        crc_data = data[..CRC32_SIZE-1]

        return "", "", "" unless validate_crc32(desearlize_crc32(crc_data), raw_data)

        header_data = data[CRC32_SIZE..HEADER_SIZE-1]
        epoc, keysz, valuesz = desearlize_header(header_data)

        key = data[CRC32_SIZE+HEADER_SIZE..CRC32_SIZE+HEADER_SIZE+keysz-1]
        value = data[CRC32_SIZE+HEADER_SIZE+keysz..]

        return epoc, key, value
    end

    def searlize_header(epoc:, keysz:, valuesz:)
        [epoc, keysz, valuesz].pack(HEADER_FORMAT)
    end

    def desearlize_header(header_data)
        header = header_data.unpack(HEADER_FORMAT)

        return header[0], header[1], header[2]
    end

    def crc32(raw_data)
        [Zlib::crc32(raw_data)].pack(CRC32_FORMAT)
    end

    def desearlize_crc32(crc_data)
        crc = crc_data.unpack(CRC32_FORMAT)

        crc[0]
    end

    def validate_crc32(digest, data)
        digest == Zlib::crc32(data)
    end
end