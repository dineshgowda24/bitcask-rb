# frozen_string_literal: true

require 'zlib'

module Bitcask
  ##
  # Serializer module encapsulates the complexties of serializing and deserializing arbitary data
  # to/from bytes stream
  module Serializer
    # Follwing are the header values stored
    # |epoc|keysz|valuesz|key_type|value_type|
    # | 4B |  4B |  4B   |  2B   |    2B    |
    # A total of 16 Bytes
    # L< : unsiged 32 bit int with little endian byte order
    # S< " unsiged 12 bit int with little endian byte order
    # Endian order does not matter, its only used to keep consitent byte ordering to ensure that db file,
    # can be seemlessly interchanged in little/big endian machines
    HEADER_FORMAT = 'L<L<L<S<S<'
    HEADER_SIZE = 16

    # 32 bit unsigned long int with little endian byte order
    CRC32_FORMAT = 'L<'
    CRC32_SIZE = 4

    DATA_TYPE = {
      Integer: 1,
      Float: 2,
      String: 3
    }.freeze

    DATA_TYPE_LOOK_UP = {
      DATA_TYPE[:Integer] => :Integer,
      DATA_TYPE[:Float] => :Float,
      DATA_TYPE[:String] => :String
    }.freeze

    DATA_TYPE_DIRECTIVE = {
      # 64 bit signed long int with little endian byte order
      DATA_TYPE[:Integer] => 'q<',
      # 64 bit double with little endian byte order
      DATA_TYPE[:Float] => 'E'
    }.freeze

    # Serializes epoc, key, value with metadata
    #
    # @param [Integer, String, String] contents to serialize
    # @return [Integer, String] Size of the serialized binary string, binary seralized string
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

    # Deserializes byte string
    #
    # @param [String] byte string to deserialize
    # @return [Integer, String|Float|Integer, String|Float|Integer] Epoc, Key, Value
    def deserialize(data)
      return 0, '', '' unless crc32_valid?(desearlize_crc32(data[..crc32_offset - 1]), data[crc32_offset..])

      epoc, keysz, valuesz, key_type, value_type = deserialize_header(data[crc32_offset..crc32_header_offset - 1])
      key_bytes = data[crc32_header_offset..crc32_header_offset + keysz - 1]
      value_bytes = data[crc32_header_offset + keysz..]

      [epoc, unpack(key_bytes, key_type), unpack(value_bytes, value_type)]
    end

    # Serializes header
    #
    # @param [Integer, String, String, Symbol, Symbol] contents to serialize
    # @return [String] Byte string
    def serialize_header(epoc:, key_type:, keysz:, value_type:, valuesz:)
      [epoc, keysz, valuesz, DATA_TYPE[key_type], DATA_TYPE[value_type]].pack(HEADER_FORMAT)
    end

    # Derializes header
    #
    # @param [String] byte string to dserialize
    # @return [Integer, String, String, Symbol, Symbol]  Epoc, keysz, valuesz, key_type, value_type
    def deserialize_header(header_data)
      header = header_data.unpack(HEADER_FORMAT)

      [header[0], header[1], header[2], DATA_TYPE_LOOK_UP[header[3]], DATA_TYPE_LOOK_UP[header[4]]]
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

    # Generates crc32 and seralizes to bytes
    #
    # @param [String] byte string
    # @return [String]  crc32 bytes
    def crc32(data_bytes)
      [Zlib.crc32(data_bytes)].pack(CRC32_FORMAT)
    end

    # Derializes crc32 byte string
    #
    # @param [String] byte string
    # @return [Integer]  crc32
    def desearlize_crc32(crc)
      crc.unpack1(CRC32_FORMAT)
    end

    def crc32_valid?(digest, data_bytes)
      digest == Zlib.crc32(data_bytes)
    end

    def pack(attribute, attribute_type)
      case attribute_type
      when :Integer, :Float
        [attribute].pack(directive(attribute_type))
      when :String
        attribute.encode('utf-8')
      else
        raise StandardError, 'Invalid attribute_type for pack'
      end
    end

    def unpack(attribute, attribute_type)
      case attribute_type
      when :Integer, :Float
        attribute.unpack1(directive(attribute_type))
      when :String
        attribute
      else
        raise StandardError, 'Invalid attribute_type for unpack'
      end
    end

    private

    def directive(attribute_type)
      DATA_TYPE_DIRECTIVE[DATA_TYPE[attribute_type]]
    end

    def type(attribute)
      attribute.class.to_s.to_sym
    end
  end
end
