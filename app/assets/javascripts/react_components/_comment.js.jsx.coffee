###* @jsx React.DOM ###

Comment = React.createClass
  render: ->
     `<div className='panel panel-default'>
         <div className='panel-heading'>
           <h4 className='panel-title'>{ this.props.author } said:</h4>
         </div>
         <div className='panel-body'>{ this.props.text }</div>
      </div>`

@Comment = Comment