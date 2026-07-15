# frozen_string_literal: true

class Ui::PassportCardComponent < ApplicationComponent
  param :passport
  option :check_ins, default: proc { [] }

  def stamp_for(event)
    Stamp.for_event(event).first
  end

  def checked_in_at_for_display(check_in)
    time_zone = check_in.event.static_metadata&.time_zone
    time_zone ? check_in.checked_in_at.in_time_zone(time_zone) : check_in.checked_in_at
  end
end
