require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
  end

  test "to_path and to_url" do
    issue = create(:issue, repository: @repo)
    assert_equal "#{@repo.to_path}/issues/#{issue.iid}", issue.to_path
    assert_equal "#{@repo.to_path}/issues/#{issue.iid}/comments", issue.to_path("/comments")
    assert_equal "#{Setting.host}#{@repo.to_path}/issues/#{issue.iid}",  issue.to_url
    assert_equal "#{Setting.host}#{@repo.to_path}/issues/#{issue.iid}#comment-1",  issue.to_url(anchor: "comment-1")
  end

  test "find_by_iid and find_by_iid!" do
    issue = create(:issue, repository: @repo)

    assert_equal issue, @repo.issues.find_by_iid(issue.iid)
    assert_equal issue, @repo.issues.find_by_iid!(issue.iid)

    assert_raise(ActiveRecord::RecordNotFound) do
      @repo.issues.find_by_iid!(0)
    end
  end

  test "issue_title" do
    issue = create(:issue, title: "Hello world")
    assert_equal "Hello world ##{issue.iid}", issue.issue_title
  end

  test "read issue" do
    issue = create(:issue)
    user1 = create(:user)
    user2 = create(:user)

    allow_feature(:reader_list) do
      user1.read_issue(issue)
      assert_equal 1, issue.reads_count
      user2.read_issue(issue)
      assert_equal 2, issue.reads_count

      assert_equal true, user1.read_issue?(issue)
      assert_equal true, user2.read_issue?(issue)
      assert_equal [user1, user2].sort, issue.read_by_users.sort
    end
  end

  test "assignee_target_users" do
    users = create_list(:user, 4)
    group = create(:group)
    group.add_member(users[0], :reader)
    group.add_member(users[1], :editor)
    group.add_member(users[2], :admin)

    repo = create(:repository, user: group)
    repo.add_member(users[3], :admin)

    issue = create(:issue, repository: repo)

    target_users = issue.assignee_target_users
    assert_equal 4, target_users.count
    assert_equal users.sort, target_users.sort
  end

  test "update_assignees" do
    users0 = create_list(:user, 3)
    users1 = create_list(:user, 2)

    issue = create(:issue)
    issue.update_assignees(users0.collect(&:id))
    issue.reload
    assert_equal users0.sort, issue.assignees.sort
    assert_equal 3, IssueAssignee.where(issue_id: issue.id).count

    issue.update_assignees(users1.collect(&:id))
    issue.reload
    assert_equal users1.sort, issue.assignees.sort
    assert_equal 2, IssueAssignee.where(issue_id: issue.id).count

    issue.update_assignees([])
    issue.reload
    assert_equal [], issue.assignees
    assert_equal 0, IssueAssignee.where(issue_id: issue.id).count
  end

  test "participants" do
    issue = create(:issue)
    user0 = create(:user)
    user1 = create(:user)
    create(:comment, commentable: issue, user: user0)
    create(:comment, commentable: issue, user: user0)
    create(:comment, commentable: issue, user: user1)
    create(:comment, commentable: issue, user: user1)
    create(:comment, commentable: issue, user_id: -999)

    assert_equal 3, issue.participants.length
    assert_equal true, issue.participants.include?(issue.user)
    assert_equal true, issue.participants.include?(user0)
    assert_equal true, issue.participants.include?(user1)
  end
end
