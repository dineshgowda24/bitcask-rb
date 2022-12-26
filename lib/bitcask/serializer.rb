# frozen_string_literal: true

require 'zlib'

module Bitcask
  module Serializer
    # epoc, keysz, valuesz, key_type, value_type
    # | 4B | 4B | 4B | 2B | 2B |
    # 16 Bytes
    # L< unsiged 32 bit int with little endian byte order
    # S< unsiged 12 bit int with little endian byte order
    HEADER_FORMAT = 'L<L<L<S<S<'
    HEADER_SIZE = 16

    # 8 bit unsigned long int, endiness is not required as its a single byte
    CRC32_FORMAT = 'L'
    CRC32_SIZE = 4

    DATA_TYPE = {
      :Integer => 1,
      :Float => 2,
      :String => 3
    }.freeze

    DATA_TYPE_LOOK_UP = {
      DATA_TYPE[:Integer] => :Integer,
      DATA_TYPE[:Float] => :Float,
      DATA_TYPE[:String] => :String
    }.freeze

    DATA_TYPE_FORMAT = {
      # 64 bit signed long int with little endian byte order
      DATA_TYPE[:Integer] => 'q<',
      # 64 bit double with little endian byte order
      DATA_TYPE[:Float] => 'E'
    }.freeze

    def serialize(epoc:, key:, value:)
      key_type = type(key)
      value_type = type(value)

      key_bytes = pack(key, key_type)
      value_bytes = pack(value, value_type)

      header = serialize_header(epoc: epoc, keysz: key_bytes.length, key_type: key_type, value_type: value_type,
                                valuesz: value_bytes.length)
      data = key_bytes + value_bytes

      [crc32_header_offset + data.length, crc32(header + data) + header + data]
    end

    def deserialize(data)
      header_and_data_bytes = data[crc32_offset..]
      crc_bytes = data[..crc32_offset - 1]

      return 0, '', '' unless validate_crc32(desearlize_crc32(crc_bytes), header_and_data_bytes)

      header_bytes = data[crc32_offset..crc32_header_offset - 1]
      epoc, keysz, valuesz, key_type, value_type = deserialize_header(header_bytes)

      key_type_sym = DATA_TYPE_LOOK_UP[key_type]
      value_type_sym = DATA_TYPE_LOOK_UP[value_type]

      key_bytes = data[crc32_header_offset..crc32_header_offset + keysz - 1]
      value_bytes = data[crc32_header_offset + keysz..]

      key = unpack(key_bytes, key_type_sym)
      value = unpack(value_bytes, value_type_sym)

      [epoc, key, value]
    end

    def serialize_header(epoc:, key_type:, keysz:, value_type:, valuesz:)
      [epoc, keysz, valuesz, DATA_TYPE[key_type], DATA_TYPE[value_type]].pack(HEADER_FORMAT)
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

    def crc32(data_bytes)
      [Zlib.crc32(data_bytes)].pack(CRC32_FORMAT)
    end

    def desearlize_crc32(crc)
      crc.unpack1(CRC32_FORMAT)
    end

    def validate_crc32(digest, data_bytes)
      digest == Zlib.crc32(data_bytes)
    end

    def pack(attribute, attribute_type)
      case attribute_type
      when :Integer, :Float
        [attribute].pack(DATA_TYPE_FORMAT[DATA_TYPE[attribute_type]])
      when :String
        attribute.encode('utf-8')
      else
        raise StandardError, 'Invalid attribute_type for pack'
      end
    end

    def unpack(attribute, attribute_type)
      case attribute_type
      when :Integer, :Float
        attribute.unpack1(DATA_TYPE_FORMAT[DATA_TYPE[attribute_type]])
      when :String
        attribute
      else
        raise StandardError, 'Invalid attribute_type for unpack'
      end
    end

    def type(attribute)
      attribute.class.to_s.to_sym
    end

  end
end
