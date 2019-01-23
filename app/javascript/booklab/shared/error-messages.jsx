export class ErrorMessages extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      hidden: false,
    }
  }

  dismiss = (e) => {
    e.preventDefault();
    this.setState({ hidden: true });
    return false;
  }

  render() {
    const { messages } = this.props;
    const { hidden } = this.state;

    if (hidden || messages.length === 0) {
      return (<div />);
    }

    return (
      <div className="flash flash-block flash-error">
        <div className="mb-1"><strong>There has {messages.length} issues:</strong></div>
        <ul className="list-style-none">
          {messages.map((message) => {
            return <li>{message}</li>
          })}
        </ul>
      </div>
    )
  }
}