class Profiles::PassportController < ApplicationController
  include ProfileData

  def index
    @check_ins = @user.passport_check_ins
    check_ins_by_uid = @check_ins.group_by(&:connect_id)
    @passports = @user.passports.sort_by { |passport|
      most_recent = check_ins_by_uid[passport.uid]&.first&.checked_in_at
      most_recent ? -most_recent.to_i : Float::INFINITY
    }
  end
end
