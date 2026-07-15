# frozen_string_literal: true

require "test_helper"

class Ui::PassportCardComponentTest < ViewComponent::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @event = events(:future_conference)
    @other_event = events(:no_sponsors_event)
  end

  test "renders the passport code and check-in count" do
    passport = ConnectedAccount.create!(user: @user, provider: "passport", uid: "PASS01")
    check_in = EventCheckIn.create!(connect_id: "PASS01", event: @event, checked_in_at: Time.zone.parse("2026-01-01 10:00"))

    render_inline(Ui::PassportCardComponent.new(passport, check_ins: [check_in]))

    assert_text "PASS01"
    assert_text "1 check-in"
  end

  test "renders the stored (upcased) uid even when claimed with lowercase input" do
    passport = ConnectedAccount.create!(user: @user, provider: "passport", uid: "pass02")

    render_inline(Ui::PassportCardComponent.new(passport, check_ins: []))

    assert_text "PASS02"
  end

  test "renders a timeline entry linking to its event" do
    passport = ConnectedAccount.create!(user: @user, provider: "passport", uid: "PASS03")
    check_in = EventCheckIn.create!(connect_id: "PASS03", event: @event, checked_in_at: Time.zone.parse("2026-01-01 10:00"))

    render_inline(Ui::PassportCardComponent.new(passport, check_ins: [check_in]))

    expected_href = Rails.application.routes.url_helpers.event_path(@event)
    assert_selector("ol li a[href='#{expected_href}']")
  end

  test "renders check-ins in the order given, without re-sorting" do
    passport = ConnectedAccount.create!(user: @user, provider: "passport", uid: "PASS04")
    newer = EventCheckIn.create!(connect_id: "PASS04", event: @other_event, checked_in_at: Time.zone.parse("2026-02-01 10:00"))
    older = EventCheckIn.create!(connect_id: "PASS04", event: @event, checked_in_at: Time.zone.parse("2026-01-01 10:00"))

    render_inline(Ui::PassportCardComponent.new(passport, check_ins: [newer, older]))

    assert_operator rendered_content.index(@other_event.name), :<, rendered_content.index(@event.name)
  end

  test "renders a per-card empty state when given zero check-ins" do
    passport = ConnectedAccount.create!(user: @user, provider: "passport", uid: "PASS05")

    render_inline(Ui::PassportCardComponent.new(passport, check_ins: []))

    assert_text "No check-ins yet on this passport"
    assert_text "PASS05"
  end
end
