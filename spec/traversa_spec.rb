require 'spec_helper'

describe Traversa do
  it 'has a version number' do
    expect(Traversa::VERSION).not_to be nil
  end

  before do
    @root = SampleResourceWithChildren.new('', nil)
    @branch = SampleResourceWithChildren.new('branch', @root)
    @root.children = { 'branch' => @branch }
    @leaf = SampleResource.new('leaf', @branch)
    @branch.children = { 'leaf' => @leaf }
  end

  describe '#traverse' do

    context 'when names is empty' do
      let(:result) { Traversa.traverse(@root, []) }

      it 'returns result where #success? is true' do
        expect(result.success?).to eq(true)
      end

      it 'returns result where #resource is the input resource' do
        expect(result.resource).to eq(@root)
      end

      it 'returns result where #subpath is empty array' do
        expect(result.subpath).to eq([])
      end
    end

    context 'when names is not empty' do
      context 'and resource does not respond to #child' do
        let(:result) { Traversa.traverse(@leaf, ['foo', 'bar']) }

        it 'returns result where #success? is false' do
          expect(result.success?).to eq(false)
        end

        it 'returns result where #resource is the input resource' do
          expect(result.resource).to eq(@leaf)
        end

        it 'returns result where #subpath is array of names' do
          expect(result.subpath).to eq(['foo', 'bar'])
        end
      end

      context 'and resource does respond to #child' do
        context 'and all names can be traversed' do
          let(:result) { Traversa.traverse(@root, ['branch', 'leaf']) }

          it 'returns result where #success? is true' do
            expect(result.success?).to eq(true)
          end

          it 'returns result where #resource is the specified resource' do
            expect(result.resource).to eq(@leaf)
          end

          it 'returns result where #subpath is empty array' do
            expect(result.subpath).to eq([])
          end
        end

        context 'and all names cannot be traversed' do
          let(:result) { Traversa.traverse(@root, ['branch', 'foo', 'bar']) }

          it 'returns result where #success? is false' do
            expect(result.success?).to eq(false)
          end

          it 'returns result where #resource is the last successfully traversed' do
            expect(result.resource).to eq(@branch)
          end

          it 'returns result where #subpath is array of remaining names' do
            expect(result.subpath).to eq(['foo', 'bar'])
          end
        end
      end

    end
  end

  describe '#resource_parents' do
    context 'when root resource' do
      it 'returns empty array' do
        expect(Traversa.resource_parents(@root)).to eq([])
      end
    end

    context 'when non-root resource' do
      it 'returns array of parents' do
        expect(Traversa.resource_parents(@leaf)).to eq([@branch, @root])
      end
    end
  end

  describe '#resource_lineage' do
    context 'when root resource' do
      it 'returns array with root as only item' do
        expect(Traversa.resource_lineage(@root)).to eq([@root])
      end
    end

    context 'when non-root resource' do
      it 'returns array of resource and its parents' do
        expect(Traversa.resource_lineage(@leaf)).to eq([@leaf, @branch, @root])
      end
    end
  end

  describe '#resource_path' do
    context 'when root resource' do
      it 'returns slash' do
        expect(Traversa.resource_path(@root)).to eq('/')
      end
      context 'when non-empty subpath' do
        it 'appends extra path elements' do
          expect(Traversa.resource_path(@root, ['foo', 'bar'])).to eq('/foo/bar')
        end
      end
    end

    context 'when non-root resource' do
      it 'returns path' do
        expect(Traversa.resource_path(@leaf)).to eq('/branch/leaf')
      end
      context 'when non-empty subpath' do
        it 'appends extra path elements' do
          expect(Traversa.resource_path(@leaf, ['foo', 'bar'])).to eq('/branch/leaf/foo/bar')
        end
      end
    end
  end
end
