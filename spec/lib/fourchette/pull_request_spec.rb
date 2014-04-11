require 'spec_helper'

describe Fourchette::PullRequest do
  describe '#perform' do
    let!(:fork) { double('fork') }
    subject { described_class.new }

    after do
      Fourchette::Fork.stub(:new).and_return(fork)
      subject.perform(params)
    end

    context 'action == synchronize' do
      let!(:params) { { 'action' => 'synchronize' } }

      it { fork.should_receive(:update) }
    end

    context 'action == closed' do
      let!(:params) { { 'action' => 'closed' } }

      it { fork.should_receive(:delete) }
    end

    context 'action == reopened' do
      let!(:params) { { 'action' => 'reopened' } }

      it { fork.should_receive(:create) }
    end

    context 'action == opened' do
      let!(:params) { { 'action' => 'opened' } }

      it { fork.should_receive(:create) }
    end
  end
end