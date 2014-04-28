require 'spec_helper'

describe 'sprout-git recipes' do
  before :all do
    expect(`which git-pair`).to be_empty
    expect(system('soloist')).to be_true
  end

  it 'install pivotal git scripts' do
    expect(`which git-pair`).not_to be_empty
  end
end
