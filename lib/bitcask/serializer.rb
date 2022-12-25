require 'zlib'

module Bitcask
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
            header = serialize_header(epoc: epoc, keysz: key.length, valuesz: value.length)
            data = key.encode("utf-8") + value.encode("utf-8")
    
            return crc32_header_offset + data.length, crc32(header+data) + header + data
        end
    
        def deserialize(data)
            raw_data = data[crc32_offset..]
            crc_data = data[..crc32_offset-1]
    
            return 0, "", "" unless validate_crc32(desearlize_crc32(crc_data), raw_data)
    
            header_data = data[crc32_offset..header_offset-1]
            epoc, keysz, valuesz = deserialize_header(header_data)
    
            key = data[crc32_header_offset..crc32_header_offset+keysz-1]
            value = data[crc32_header_offset+keysz..]
    
            return epoc, key, value
        end
    
        def serialize_header(epoc:, keysz:, valuesz:)
            [epoc, keysz, valuesz].pack(HEADER_FORMAT)
        end
    
        def deserialize_header(header_data)
            header = header_data.unpack(HEADER_FORMAT)
            
            return header[0], header[1], header[2]
        end
    
        private
    
        def crc32_offset
            CRC32_SIZE
        end
    
        def header_offset
            HEADER_SIZE
        end
    
        def crc32_header_offset
            crc32_offset+header_offset
        end
    
        def crc32(raw_data)
            [Zlib::crc32(raw_data)].pack(CRC32_FORMAT)
        end
    
        def desearlize_crc32(crc_data)
            crc_data.unpack(CRC32_FORMAT)[0]
        end
    
        def validate_crc32(digest, data)
            digest == Zlib::crc32(data)
        end
    end
end