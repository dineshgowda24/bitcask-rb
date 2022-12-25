require 'ostruct'

module Bitcask 
    class DiskStore
        include Serializer

        def initialize(db_file="bitcask.db")
          @db_fh = File.open(db_file, "a+b")
          @write_pos = 0
          @key_dir = {}

          init_key_dir
        end

        def [](key)
            key_struct = @key_dir[key]
            return "" if key_struct.nil?

            @db_fh.seek(key_struct.write_pos)
            raw = @db_fh.read(key_struct.size)
            epoc, key, value = deserialize(raw)
            
            value
        end

        def []=(key, value)
            size, data = serialize(epoc: Time.now.to_i, key: key, value: value)

            @key_dir[key] = key_struct(@write_pos, size, key)
            persist(data)
            incr_write_pos(size)
        end

        private

        def persist(data)
            @db_fh.write(data)
            @db_fh.flush
        end

        def incr_write_pos(pos)
            @write_pos += pos
        end

        def key_struct(write_pos, size, key)
            OpenStruct.new(write_pos: write_pos, size: size, key: key)
        end

        def init_key_dir
            while crc_and_header = @db_fh.read(crc32_header_offset) do
                
                header = crc_and_header[crc32_offset..]
                epoc, keysz, valuesz = deserialize_header(header)

                key = @db_fh.read(keysz)
                value = @db_fh.read(valuesz)

                crc = crc_and_header[..crc32_offset-1]
                raise Error("file corrupted") unless validate_crc32(desearlize_crc32(crc), header+key+value)
                
                size = crc32_header_offset + keysz + valuesz
                @key_dir[key] = OpenStruct.new(write_pos: @write_pos, size: size, key: key)
                incr_write_pos(size)
            end 
        end
    end
end