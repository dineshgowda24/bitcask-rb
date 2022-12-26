# frozen_string_literal: true

require 'zlib'

module Bitcask
  module Serializer
    # tz, keysz, valuesz, keytype, valuetype
    # 3, 2 - 32, 16 bit unsigned long int with little endian byte order
    HEADER_FORMAT = 'L<L<L<S<S<'
    HEADER_SIZE = 16

    # 32 bit unsigned long int
    CRC32_FORMAT = 'L'
    CRC32_SIZE = 4

    TYPES = {
      'Integer' => 1,
      'Float' => 2,
      'String' => 3
    }.freeze

    TYPES_LOOK_UP = {
      TYPES['Integer'] => 'Integer',
      TYPES['Float'] => 'Float',
      TYPES['String'] => 'String'
    }.freeze

    TYPES_FORMAT = {
      TYPES['Integer'] => 'q<', # 64 bit signed long int
      TYPES['Float'] => 'E' # 64 bit double
    }.freeze

    def serialize(epoc:, key:, value:)
      key_type = key.class.to_s
      value_type = value.class.to_s

      key_raw = pack(key, key_type)
      value_raw = pack(value, value_type)

      header = serialize_header(epoc: epoc, keysz: key_raw.length, key_type: key_type, value_type: value_type,
                                valuesz: value_raw.length)
      data = key_raw + value_raw

      [crc32_header_offset + data.length, crc32(header + data) + header + data]
    end

    def deserialize(data)
      raw_data = data[crc32_offset..]
      crc_data = data[..crc32_offset - 1]

      return 0, '', '' unless validate_crc32(desearlize_crc32(crc_data), raw_data)

      header_data = data[crc32_offset..crc32_header_offset - 1]
      epoc, keysz, valuesz, key_type, value_type = deserialize_header(header_data)

      key_type = TYPES_LOOK_UP[key_type]
      value_type = TYPES_LOOK_UP[value_type]

      key_raw = data[crc32_header_offset..crc32_header_offset + keysz - 1]
      value_raw = data[crc32_header_offset + keysz..]

      key = unpack(key_raw, key_type)
      value = unpack(value_raw, value_type)

      [epoc, key, value]
    end

    def serialize_header(epoc:, key_type:, keysz:, value_type:, valuesz:)
      [epoc, keysz, valuesz, TYPES[key_type], TYPES[value_type]].pack(HEADER_FORMAT)
    end

    def deserialize_header(header_data)
      header = header_data.unpack(HEADER_FORMAT)

      [header[0], header[1], header[2], header[3], header[4]]
    end

    def crc32_offset
      CRC32_SIZE
    end

    def header_offset
      HEADER_SIZE
    end

    def crc32_header_offset
      crc32_offset + header_offset
    end

    def crc32(raw_data)
      [Zlib.crc32(raw_data)].pack(CRC32_FORMAT)
    end

    def desearlize_crc32(crc_data)
      crc_data.unpack1(CRC32_FORMAT)
    end

    def validate_crc32(digest, data)
      digest == Zlib.crc32(data)
    end

    def pack(attribute, attribute_type)
      case attribute_type
      when 'Integer', 'Float'
        [attribute].pack(TYPES_FORMAT[TYPES[attribute_type]])
      when 'String'
        attribute.encode('utf-8')
      else
        raise StandardError, 'Invalid attribute_type'
      end
    end

    def unpack(attribute, attribute_type)
      case attribute_type
      when 'Integer', 'Float'
        attribute.unpack1(TYPES_FORMAT[TYPES[attribute_type]])
      when 'String'
        attribute
      else
        raise StandardError, 'Invalid attribute_type'
      end
    end
  end
end
