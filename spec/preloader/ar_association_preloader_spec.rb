# frozen_string_literal: true

require 'spec_helper'

describe Priloo::Preloaders::ArAssociationPreloader do
    let(:post) { Post.create!(user: User.create!) }
    let(:preloader) { described_class.new(Post, :user) }

    before { post.send(:clear_association_cache) }

    describe '#dependencies' do
        it { expect(preloader.dependencies).to be_empty }
    end

    describe '#preload' do
        let(:preloaded_user) { preloader.preload([post, post]).first }
        it { expect(preloader.injected?(post)).to be_falsy }
        it { expect(preloaded_user.posts).to eq [post] }

        class Dpost < SimpleDelegator; end

        context 'when active_record is behind a delegator' do
            let(:delegated_post) { Dpost.new(post) }
            let(:preloaded_user) { preloader.preload([delegated_post]).first }

            it { expect(preloader.injected?(post)).to be_falsy }
            it { expect(preloaded_user.posts).to eq [post] }
        end

        context 'when has_many relation' do
            let(:user) { User.create!.tap { |u| Post.create!(user: u) } }
            let(:preloader) { described_class.new(User, :posts) }

            let(:preloaded_users) { preloader.preload([user, user]) }

            it { expect(preloader.injected?(user)).to be_falsy }
            it { expect(preloaded_users.map(&:size)).to eq [1, 1] }
        end
    end
end
