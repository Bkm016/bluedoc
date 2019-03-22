import Assignee from "./Assignee";
import UserAvatar from "../users/UserAvatar";

export default class Sidebar extends React.PureComponent {
  constructor(props) {
    super(props);
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`issues.Sidebar${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { participants } = this.props;

    return <div className="issue-sidebar">
      <Assignee {...this.props} />

      <div className="sidebar-box issue-participants mt-3">
        <h2 className="sub-title">{participants.length} {this.t(".Participants")}</h2>
        <div className="item-list">
          {participants.map(user => <UserAvatar user={user} style="tiny" />)}
        </div>
      </div>
    </div>
  }
}