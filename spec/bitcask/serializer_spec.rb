# frozen_string_literal: true

RSpec.describe Bitcask::Serializer do
  let(:crc_size) { 4 }
  let(:header_size) { 12 }
  let(:crc_and_header_size) { 16 }
  let(:subject) { Class.new { extend Bitcask::Serializer } }
  let(:now) { Time.now.to_i }

  describe '#serialize' do
    let(:key) { Faker::Lorem.word }
    let(:value) { Faker::Lorem.sentence(word_count: 10000) }

    it 'returns serialized data and its size' do
      size, data = subject.serialize(epoc: now, key:, value:)

      expect(size).to eq(crc_and_header_size + key.length + value.length)
      expect(data).not_to be_empty
    end
  end

  describe '#serialize_header' do
    it 'returns serialized header' do
      data = subject.serialize_header(epoc: now, keysz: 10, valuesz: 20)

      expect(data.length).to eq(header_size)
      expect(data).not_to be_empty
    end
  end

  describe '#deserialize' do
    let(:serialized_data) do
      OpenStruct.new(raw: "\xCEi\x94\x03}\xA7\xA8c\x05\x00\x00\x00\t\x00\x00\x00animeOne Piece",
                     epoc: 1_671_997_309, key: 'anime', value: 'One Piece')
    end

    context 'when a valid data is passed' do
      it 'returns epoc, key and value' do
        epoc, key, value = subject.deserialize(serialized_data.raw)

        expect(epoc).to eq(serialized_data.epoc)
        expect(key).to eq(serialized_data.key)
        expect(value).to eq(serialized_data.value)
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
      OpenStruct.new(raw: "\x1F\xAB\xA8c\n\x00\x00\x00\x14\x00\x00\x00", epoc: 1_671_998_239, keysz: 10,
                     valuesz: 20)
    end

    it 'returns epoc, keysz and valuesz' do
      epoc, keysz, valuesz = subject.deserialize_header(serialized_header_data.raw)

      expect(epoc).to eq(serialized_header_data.epoc)
      expect(keysz).to eq(serialized_header_data.keysz)
      expect(valuesz).to eq(serialized_header_data.valuesz)
    end
  end
end
