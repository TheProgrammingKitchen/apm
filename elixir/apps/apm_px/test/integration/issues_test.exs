defmodule ApmPx.E2EIssuesTest do
  use ApmPx.SessionHelper

  describe "E2E Issues" do

    @tag :hound
    test "GET /issues lists loaded issues when logged in" do
      login_as("user", "developer")

      navigate_to("http://localhost:4000/issues")
      assert visible_text({:id, "issues"}) =~ "Item Number One"
      assert visible_text({:id, "issues"}) =~ "Item Number Two"
      assert visible_text({:id, "issues"}) =~ "Daughter of item 1"
      assert visible_text({:id, "issues"}) =~ "Son of item 1"
    end

    @tag :hound
    test "GET /issues when not logged in shows error" do
      navigate_to("http://localhost:4000/issues")
      assert visible_text({:class, "error"}) =~ "Please login first"
      refute visible_page_text() =~ "Item Number One"
    end

    @tag :hound
    test "POST /issues creates a new issue in repo" do
      login_as("user", "developer")
      navigate_to("http://localhost:4000/issues/new")

      fill_field({:name, "issue[subject]"}, "A New Subject")
      submit_element({:name, "issue[subject]"})

      assert visible_text({:class, "alert-success"}) =~ "Issue successfully created"
    end

    @tag :hound
    test "Edit an issue" do
      login_as("user", "developer")
      navigate_to("http://localhost:4000/issues/new")
      fill_field({:name, "issue[subject]"}, "A-1-1")
      fill_field({:name, "issue[description]"}, "Original Description")
      submit_element({:name, "issue[subject]"})
      
      click({:id, "edit-A-1-1"})
      fill_field({:name, "issue[description]"}, "A Modified Issue")
      submit_element({:name, "issue[subject]"})

      assert visible_text({:class, "alert-success"}) =~ "Issue successfully updated"
      assert visible_text({:class, "issue-index"}) =~ "A-1-1"
      assert visible_text({:class, "issue-index"}) =~ "A Modified Issue"
    end
  end

end
