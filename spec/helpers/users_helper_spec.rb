require 'spec_helper'

describe UsersHelper do

  describe "gravatar_for" do
    let(:email) { "ABcd@Google.COM" }
    let(:name) { "ThisIsMyName" }
    let(:user) { double("user", email: email, name: name) }
    let(:hash_id) { Digest::MD5::hexdigest(email.downcase) }

    it "should request the correct URL" do
      gravatar_for(user).should match("avatar/#{hash_id}")
    end

    it "should generate an image tag" do
      gravatar_for(user).should match("<img ")
    end

    it "should have the name as alternative text" do
      gravatar_for(user).should match("alt=\"#{name}\"")
    end

    it "should accept a size option" do
      gravatar_for(user, size: 40)
    end

    it "should set the size option as a query parameter" do
      gravatar_for(user, size: 40).should match("s=40")
    end
  end

end