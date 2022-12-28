# frozen_string_literal: true

require 'ostruct'

module Bitcask
  ##
  # This class represents a persistant store via a database file
  class DiskStore
    include Serializer

    ##
    # Creates a new store described by a database file
    #
    # If the file already exists, then contents of key_dir will be populated.
    # A StandardError will be raised when the file is corrupted.
    def initialize(db_file = 'bitcask.db')
      @db_fh = File.open(db_file, 'a+b')
      @write_pos = 0
      @key_dir = {}

      init_key_dir
    end

    def [](key)
      get(key)
    end

    def []=(key, value)
      put(key, value)
    end

    # Get the value for the given key
    # When the key does not exist, it returns empty string
    #
    # @param [String] key
    # @return [Value] value of the given key
    def get(key)
      key_struct = @key_dir[key]
      return '' if key_struct.nil?

      @db_fh.seek(key_struct[:write_pos])
      raw = @db_fh.read(key_struct[:log_size])
      epoc, key, value = deserialize(raw)

      value
    end

    # Sets a new key value pair
    #
    # @param [String, String] key and value
    # @return [nil]
    def put(key, value)
      log_size, data = serialize(epoc: Time.now.to_i, key: key, value: value)

      @key_dir[key] = key_struct(@write_pos, log_size, key)
      persist(data)
      incr_write_pos(log_size)

      nil
    end

    def keys
      @key_dir.keys
    end

    def size
      @key_dir.length
    end

    def flush
      @db_fh.flush
    end

    def close
      flush
      @db_fh.close
    end

    private

    def persist(data)
      @db_fh.write(data)
      @db_fh.flush
    end

    def incr_write_pos(pos)
      @write_pos += pos
    end

    def key_struct(write_pos, log_size, key)
      { write_pos: write_pos, log_size: log_size, key: key }
    end

    def init_key_dir
      while (crc_and_header_bytes = @db_fh.read(crc32_header_offset))

        header_bytes = crc_and_header_bytes[crc32_offset..]
        epoc, keysz, valuesz, key_type, value_type = deserialize_header(header_bytes)

        key_bytes = @db_fh.read(keysz)
        value_bytes = @db_fh.read(valuesz)

        key = unpack(key_bytes, key_type)
        value = unpack(value_bytes, value_type)

        crc = crc_and_header_bytes[..crc32_offset - 1]
        raise StandardError, 'file corrupted' unless crc32_valid?(desearlize_crc32(crc),
                                                                  header_bytes + key_bytes + value_bytes)

        log_size = crc32_header_offset + keysz + valuesz
        @key_dir[key] = key_struct( @write_pos, log_size, key)
        incr_write_pos(log_size)
      end
    end
  end
end
