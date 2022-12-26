# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Bitcask::DiskStore do
  let(:test_db_file) { 'bitcask_test.db' }
  let(:test_db_fixture_file) { db_fixture_file_path }

  describe '#put' do
    subject { described_class.new(test_db_file) }

    after do
      File.delete(test_db_file)
    end

    it 'puts a kv pair on the disk' do
      expect(subject.put(Faker::Lorem.word, Faker::Lorem.sentence)).to be_nil
      expect(subject.put(Faker::Lorem.word, Faker::Lorem.sentence(word_count: 10))).to be_nil
      expect(subject.put(Faker::Lorem.word, Faker::Lorem.sentence(word_count: 100))).to be_nil
      expect(subject.put(Faker::Lorem.word, Faker::Lorem.sentence(word_count: 1000))).to be_nil
      expect(subject.put(Faker::Lorem.word, Faker::Lorem.sentence(word_count: 10_000))).to be_nil
    end
  end

  describe '#get' do
    context 'when the db file is present' do
      subject { described_class.new(test_db_fixture_file) }

      context 'when the key is not present' do
        it 'returns empty string' do
          expect(subject.get('Anime')).to eq('')
        end
      end

      context 'when the key is present' do
        it 'returns value' do
          expect(subject.get('ut')).to eq('Voluptatum esse non vero ut vitae harum blanditiis ducimus vel nam rerum quia ipsa necessitatibus quo eaque animi ab voluptatem sed sunt non ipsam aut velit rerum perspiciatis quasi doloribus omnis eum et reprehenderit qui minima aut illo veritatis atque sequi quas eius consequatur magni saepe numquam molestias odio beatae quo maiores dignissimos illum aut sint qui porro sed in enim enim asperiores et tenetur voluptas maxime possimus quidem accusantium laudantium aliquam ipsum voluptates consequuntur et tempora cumque voluptatem dolor tempore sint nemo ex omnis repudiandae aliquid pariatur neque nostrum debitis odit qui nihil voluptatem minus temporibus voluptatem ut sit.')
          expect(subject.get('saepe')).to eq('Non autem magni non quaerat non eos enim amet qui molestiae pariatur quam rerum facilis nulla tempora reprehenderit ipsa rerum sunt ducimus aspernatur magni blanditiis blanditiis eveniet sed nobis quisquam iusto quia corporis in deleniti repellendus iure similique facere maxime beatae aut quidem fuga labore laborum reprehenderit suscipit eveniet molestias aspernatur vel minus sunt quo reprehenderit sint deserunt corporis velit hic recusandae et voluptatem ipsa dolores eos facere eum qui ut nam et aperiam voluptatibus minima laborum doloremque officiis optio eaque voluptatibus et sint dicta esse ab ex ut cumque temporibus alias voluptatum qui iusto laboriosam nihil qui veritatis aut pariatur et sint rerum fugiat reiciendis non quia atque blanditiis et suscipit unde magni iste ea voluptates ex ad expedita eum ut quasi et adipisci reiciendis et a earum enim excepturi autem vel accusantium qui veniam est qui odio voluptatem aut deleniti omnis quia placeat ut modi nostrum tempora est labore ipsa accusamus et sit eum delectus nobis dolores laboriosam omnis est sed voluptatem neque ut dicta et est et dolor vero quis praesentium minima ut voluptas omnis ut velit sed eum harum veniam dignissimos tempora aliquid et consectetur in ducimus cum molestiae dolor hic quisquam sed tenetur non quam eaque fugiat ea qui esse recusandae nisi officia provident dolores facere voluptatem corrupti distinctio magnam perferendis sunt soluta ut perspiciatis laudantium officia veniam quia magnam sunt libero corporis ut nisi est reprehenderit saepe ut debitis et eum ipsum illo iste animi expedita rerum totam et animi temporibus voluptatum minus amet illum inventore vel aut dolorem est necessitatibus rem fugit est omnis laudantium dolor fugit sit distinctio voluptates voluptatem aut exercitationem placeat rerum molestias corrupti earum impedit numquam minima eum voluptate in quasi illo quo veritatis perferendis et est numquam sit quo dolores dolorem animi consectetur voluptatem est expedita commodi reprehenderit inventore accusamus nostrum sapiente adipisci molestiae nam et itaque odit assumenda cupiditate deserunt vel aut cupiditate quidem quo ut dolores aut ut ad nihil aut dolores sed eaque modi molestiae debitis qui omnis eius dicta dolorem odit ut et eveniet et repellat sit omnis porro nemo qui ullam culpa explicabo accusantium omnis aut ipsum sed dignissimos odit fugit cumque harum nihil ut repudiandae nisi impedit aut dolor velit nemo a nulla facilis eum optio quaerat repellendus expedita dolores sunt perferendis ullam optio ullam consequatur iste id saepe officiis aspernatur ea rerum et nesciunt sit velit et dolorem quo quam alias in omnis et quos consequatur consequatur natus ut ut mollitia ut quae sed hic et ex quae ut libero doloremque unde rem esse sint maiores cumque maiores non ratione vitae perferendis ratione qui sapiente doloribus consequuntur consequatur dicta laudantium eligendi qui voluptas voluptate amet vel quas sunt qui similique tenetur culpa alias accusamus repellat eos sint facere qui labore facilis vitae aliquam voluptates ipsum voluptatem voluptate est dolorum autem quia illum ea aliquid molestias voluptatem ipsam atque eaque mollitia minus excepturi aliquam est iure impedit deleniti occaecati et nemo dignissimos totam illo laudantium temporibus magni suscipit tempora veritatis aut autem ut quis necessitatibus natus maiores dignissimos nulla alias adipisci recusandae quis doloribus ipsam consequatur et quis eum inventore et architecto neque at sed aliquam asperiores voluptatem vel libero asperiores natus tempore sint distinctio voluptatem est commodi sequi saepe molestiae tempora maxime dolor facilis nesciunt repudiandae corporis consequatur similique itaque eum tempore et ex ipsa deserunt possimus ullam odio aut repellat molestiae earum ea et sit doloribus provident fugit eveniet sit excepturi adipisci nostrum ab corrupti quia harum omnis quia non deleniti libero et maiores consequatur eligendi accusantium quod nihil minus ut dicta voluptatem dolor distinctio sit harum dolorum est tenetur itaque quia vel est ratione atque ex voluptas est aut molestiae est sapiente commodi saepe atque possimus rerum nihil aut neque eum repellat porro hic est debitis sequi qui optio nam tempore aut nobis assumenda blanditiis commodi occaecati reiciendis et fuga hic rerum aut aut nam ut doloribus assumenda sit assumenda et dolorem nobis error debitis maxime et quod commodi asperiores voluptas velit earum et delectus enim qui quod sit corporis est totam blanditiis mollitia dolores voluptatem consequatur sunt ut cumque a et id consequuntur molestias eos occaecati mollitia at pariatur nesciunt reiciendis corrupti voluptatibus quia laboriosam excepturi qui cum odit neque dolore accusamus cupiditate et veniam animi necessitatibus nesciunt totam dolorem qui ea dolorum doloribus et odio sit fugit eos facere culpa perspiciatis ipsa consequuntur modi velit quidem aperiam labore consequatur animi ipsam exercitationem sed ipsam aperiam labore at cum tenetur dolor provident consequatur nobis quibusdam quaerat vel alias deserunt sed voluptas et et consectetur consequatur quos deleniti in dolorum ab voluptates quo id expedita quas eius esse quo explicabo fuga tempore ut quo velit enim voluptatibus voluptas placeat voluptas id porro molestiae autem accusantium sed voluptas voluptatem maxime enim illum sint omnis qui aperiam aliquam quis aut voluptatum in aut recusandae illum quia et quae quaerat asperiores explicabo autem sunt recusandae accusamus eius praesentium qui in quis voluptas nulla aut magnam quia sapiente ea eius est error soluta autem molestias enim rerum quod sed laborum rem delectus ea adipisci rerum cumque id harum enim omnis repellat veniam sed nostrum numquam quas incidunt quibusdam esse similique nemo qui autem perspiciatis non pariatur et beatae nisi repellendus itaque officiis consequatur qui cum voluptatem et placeat non sed aspernatur amet unde aut suscipit cupiditate doloremque soluta veritatis magni nihil error et totam sint porro et nostrum aut unde officia dolorem quia unde corrupti libero rem et et natus est vero consectetur modi quibusdam voluptatem fugiat dolore incidunt reiciendis asperiores nihil veritatis amet velit quo et eligendi numquam in ea id ut iure id sequi in consequatur id facilis dolore voluptas voluptatem quia qui quibusdam qui quos exercitationem ad omnis vitae sunt voluptate qui quo aut quod possimus est quos dolorem quasi aspernatur provident beatae iusto officia nihil voluptatum et et praesentium explicabo ut itaque id laboriosam aliquid autem ipsum quos vero id inventore quis officiis ad temporibus quisquam sit deserunt fugiat incidunt repellendus cum magnam quidem enim consectetur maxime laborum rerum.')
          expect(subject.get('suscipit')).to eq('Quia sapiente maiores sunt.')
        end
      end
    end

    context 'when the db file is not present' do
      subject { described_class.new(test_db_file) }

      after do
        File.delete(test_db_file)
      end

      context 'when the key is not present' do
        it 'returns empty string' do
          expect(subject.get(Faker::Lorem.word)).to eq('')
        end
      end

      context 'when the key is present' do
        let(:key_1) { Faker::Lorem.word }
        let(:key_2) { Faker::Lorem.word }
        let(:value_1) { Faker::Lorem.sentence(word_count: 10_000) }
        let(:value_2) { Faker::Lorem.sentence(word_count: 100_000) }

        before do
          subject.put(key_1, value_1)
          subject.put(key_2, value_2)
        end

        it 'returns value' do
          expect(subject.get(key_1)).to eq(value_1)
          expect(subject.get(key_2)).to eq(value_2)
        end
      end
    end
  end

  describe '#keys' do
    context 'when the db file is present' do
      subject { described_class.new(test_db_fixture_file) }

      context 'when the db file has data' do
        it 'returns an array of keys' do
          expect(subject.keys.length).to eq(5)
          expect(subject.keys).to eq(%w[suscipit dolores ut saepe illo])
        end
      end
    end

    context 'when the db file is not present' do
      subject { described_class.new(test_db_file) }

      after do
        File.delete(test_db_file)
      end

      context 'when the db file is empty' do
        it 'returns an empty array' do
          expect(subject.keys.length).to eq(0)
          expect(subject.keys).to eq([])
        end
      end

      context 'when the db file is not empty' do
        let(:key_1) { Faker::Lorem.word }
        let(:key_2) { Faker::Lorem.word }
        let(:value_1) { Faker::Lorem.sentence(word_count: 10_000) }
        let(:value_2) { Faker::Lorem.sentence(word_count: 100_000) }

        before do
          subject.put(key_1, value_1)
          subject.put(key_2, value_2)
        end

        it 'returns an empty array' do
          expect(subject.keys.length).to eq(2)
          expect(subject.keys).to eq([key_1, key_2])
        end
      end
    end
  end
end
