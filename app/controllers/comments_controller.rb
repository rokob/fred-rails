class CommentsController < ApplicationController
  def index
    @presenter = {
      :comments => Comment.all,
      :form => {
        :action => comments_path,
        :csrf_param => request_forgery_protection_token,
        :csrf_token => form_authenticity_token
      }
    }
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save

    if request.xhr?
      render :json => Comment.all
    else
      redirect_to comments_path
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:author, :text)
    end

end

class Comment
  FILEPATH = Rails.root.join('comments.dat')

  attr_reader :author, :text

  def initialize(params)
    @author = params[:author]
    @text = params[:text]
  end

  def self.save(comments)
    File.open(FILEPATH, 'w') do |file|
      file.print Marshal::dump(comments)
    end
  end

  def self.all
    return [] unless File.exists?(FILEPATH)
    Marshal::load(File.read(FILEPATH))
  end

  def save
    Comment.save Comment.all[0...4].unshift(self)
  end

  def as_json(options)
    id = [('a'..'f'),(0..9)].map(&:to_a).inject(:+).shuffle[0..8].join
    {'id' => id, 'author' => @author, 'text' => @text}
  end
end