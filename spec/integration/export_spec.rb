require 'spec_helper'
require 'teaspoon/export'

describe '--export' do
  shared_examples 'all exports' do
    let(:index_file) { File.join(output_dir, suite, 'index.html') }

    it 'creates the output directory' do
      expect(File.directory?(output_dir)).to be_true
    end

    it 'has an index.html in the suite directory' do
      expect(File.exists?(index_file)).to be_true
      expect(File.read(index_file)).to include '<html>'
    end

    it 'does not reference files above the root directory' do
      expect(File.read(index_file)).not_to include '"../'
    end

    it 'removes the query portion of downloaded filenames' do
      expect(Dir.glob(File.join('**', '*\?*')).size).to eq 0
      expect(File.read(index_file)).not_to include '%3F'
    end

    it 'moves files out of the directory created by wget with the hostname' do
      expect(Dir.glob(File.join('**', '127.0.0.1*', '*')).size).to eq 0
    end

    after(:all) do
      FileUtils.rm_rf output_dir
    end
  end

  context 'with no suite specified' do
    def suite
      'default'
    end

    context 'using the default location' do
      def output_dir
        File.expand_path('./teaspoon-export')
      end

      before(:all) do
        FileUtils.rm_rf output_dir
        Teaspoon::Export.run_silently('ruby', '-Ilib', 'bin/teaspoon', '-e')
      end

      it_behaves_like 'all exports'
    end

    context 'with a given location' do
      def output_dir
        '/tmp/teaspoon-output'
      end

      before(:all) do
        FileUtils.rm_rf output_dir
        Teaspoon::Export.run_silently('ruby', '-Ilib', 'bin/teaspoon', "--export=#{output_dir}")
      end

      it_behaves_like 'all exports'
    end
  end

  context 'with a suite specified' do
    def output_dir
      '/tmp/teaspoon-output'
    end

    def suite
      'jasmine'
    end

    before(:all) do
      FileUtils.rm_rf output_dir
      Teaspoon::Export.run_silently('ruby', '-Ilib', 'bin/teaspoon', '-e', output_dir, '-s', suite)
    end

    it_behaves_like 'all exports'
  end
end
