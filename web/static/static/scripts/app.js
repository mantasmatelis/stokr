
var React = window.React = require('react'),
    mountNode = document.getElementById("app");

import Banner from './ui/banner.jsx';
import About from'./ui/about.jsx';
import Signup from './ui/signup.jsx';

var top;
var about;

var App = React.createClass({

    getInitialState: function() {
        return { page: "home" };
    },

    componentWillMount : function() {
        if (this.state.page === "home"){
            top = <Banner onClick={this.handleButtonClick} />;
        }
        else {
            top = <Signup />;
        }
    },

    componentDidMount: function() {
        about= React.findDOMNode(this.refs.about);
    },

    componentWillUpdate: function() {
        if (this.state.page === "signup") {
            top = <Signup />;
        }
    },

    handleButtonClick: function(e) {
        console.log(e.target.className);
        if(e.target.className === "signup") {
            this.setState({ page: "signup"});
        }
    },

    render: function() {
        return (
        <div className="app">
            {top}
            <About ref="about" onClick={this.handleButtonClick} />
        </div>
        );
    }
});


React.render(<App />, mountNode);

