require 'spec_helper'

describe User do
  before(:each) do
    @user = User.new(name: "Bill", email: "bill@gmail.com")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }

  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a"*51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should not be valid" do
      bad = %w{user@foo,com quax.io.com 
               example.foo@org foo@bar+bax.com 
               fux@baz_bom.com foo@gmail.co..uk}
      bad.each do |address|
        @user.email = address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is invalid" do
    it "should not be valid" do
      good = %w{user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn andy@gmail.co.uk}
      good.each do |address|
        @user.email = address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when different case email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
end
