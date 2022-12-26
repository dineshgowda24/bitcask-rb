# frozen_string_literal: true

RSpec.describe Bitcask::Serializer do
  let(:crc_size) { 4 }
  let(:header_size) { 16 }
  let(:crc_and_header_size) { header_size + crc_size }
  let(:subject) { Class.new { extend Bitcask::Serializer } }
  let(:now) { Time.now.to_i }

  describe '#serialize' do
    let(:key) { Faker::Lorem.word }
    let(:value) { Faker::Lorem.sentence(word_count: 10_000) }

    it 'returns serialized data and its size' do
      size, data = subject.serialize(epoc: now, key: key, value: value)

      expect(size).to eq(crc_and_header_size + key.length + value.length)
      expect(data).not_to be_empty
    end
  end

  describe '#serialize_header' do
    it 'returns serialized header' do
      data = subject.serialize_header(epoc: now, keysz: 10, valuesz: 20, key_type: "Integer", value_type: "Integer")

      expect(data.length).to eq(header_size)
      expect(data).not_to be_empty
    end
  end

  describe '#deserialize' do
    let(:serialized_data_1) do
      OpenStruct.new(raw: "<\v\x90\x8C\x01\xC1\xA9c\b\x00\x00\x00\b\x00\x00\x00\x01\x00\x02\x00\x01\x00\x00\x00\x00\x00\x00\x00333333\xF3?",
                     epoc: 1_672_069_377, key: 1, value: 1.2)
    end
    let(:serialized_data_2) do
      OpenStruct.new(raw: "\xFE\xE9\xD2.\x01\xC1\xA9c\b\x00\x00\x00\b\x00\x00\x00\x02\x00\x01\x00333333\xF3?\x02\x00\x00\x00\x00\x00\x00\x00",
                     epoc: 1_672_069_377, key: 1.2, value: 2)
    end
    let(:serialized_data_3) do
      OpenStruct.new(raw: "\xBA\xFD\x0EA\x01\xC1\xA9c\x05\x00\x00\x00\t\x00\x00\x00\x03\x00\x03\x00AnimeOne Piece",
                     epoc: 1_672_069_377, key: 'Anime', value: 'One Piece')
    end

    context 'when a valid data is passed' do
      it 'returns epoc, key and value' do
        epoc, key, value = subject.deserialize(serialized_data_1.raw)

        expect(epoc).to eq(serialized_data_1.epoc)
        expect(key).to eq(serialized_data_1.key)
        expect(value).to eq(serialized_data_1.value)
      end

      it 'returns epoc, key and value' do
        epoc, key, value = subject.deserialize(serialized_data_2.raw)

        expect(epoc).to eq(serialized_data_2.epoc)
        expect(key).to eq(serialized_data_2.key)
        expect(value).to eq(serialized_data_2.value)
      end

      it 'returns epoc, key and value' do
        epoc, key, value = subject.deserialize(serialized_data_3.raw)

        expect(epoc).to eq(serialized_data_3.epoc)
        expect(key).to eq(serialized_data_3.key)
        expect(value).to eq(serialized_data_3.value)
      end
    end

    context 'when an empty string is passed' do
      it 'raises size as 0 and empty string' do
        epoc, key, value = subject.deserialize('')

        expect(epoc).to eq(0)
        expect(key).to eq('')
        expect(value).to eq('')
      end
    end

    context 'when crc is invalid' do
      it 'returns size as 0 and empty string' do
        epoc, key, value = subject.deserialize("\xCEi\x94\x03}\xA7\xA8c\x05\x00\x00\x00\t\x00\x00\x00animeTwo Piece")

        expect(epoc).to eq(0)
        expect(key).to eq('')
        expect(value).to eq('')
      end
    end
  end

  describe '#deserialize_header' do
    let(:key) { 'anime' }
    let(:value) { 'One Piece' }
    let(:serialized_header_data) do
      OpenStruct.new(raw: "\xF5\xC1\xA9c\n\x00\x00\x00\x14\x00\x00\x00\x01\x00\x01\x00", epoc: 1_672_069_621, keysz: 10,
                     valuesz: 20, value_type: 1, key_type: 1)
    end

    it 'returns epoc, keysz and valuesz' do
      epoc, keysz, valuesz, key_type, value_type = subject.deserialize_header(serialized_header_data.raw)

      expect(epoc).to eq(serialized_header_data.epoc)
      expect(keysz).to eq(serialized_header_data.keysz)
      expect(valuesz).to eq(serialized_header_data.valuesz)
      expect(key_type).to eq(serialized_header_data.key_type)
      expect(value_type).to eq(serialized_header_data.value_type)
    end
  end
end
