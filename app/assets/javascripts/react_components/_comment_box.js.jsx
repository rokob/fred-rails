/** @jsx React.DOM */

var CommentBox = React.createClass({
  getInitialState: function () {
    return JSON.parse(this.props.presenter);
  },

  handleCommentSubmit: function ( formData, action ) {
    $.ajax({
      data: formData,
      url: action,
      type: "POST",
      dataType: "json",
      success: function ( data ) {
        this.setState({ comments: data });
        $('#comment_notice').removeClass('hide')
                            .html('Comment Posted!').fadeIn(200);
        $('#comment_notice').fadeOut(2000, function() {
                              $(this).addClass('hide');
                            });
      }.bind(this)
    });
  },

  render: function () {
    return (
      <div className="comment-box">
        <img src={ this.props.imgSrc } alt={ this.props.imgAlt } title={ this.props.imgAlt } className="center" />
        <CommentList comments={ this.state.comments } />
        <hr />
        <h2>Add a comment:</h2>
        <CommentForm form={ this.state.form } onCommentSubmit={ this.handleCommentSubmit } />
      </div>
    );
  }
});