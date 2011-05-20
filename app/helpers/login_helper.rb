require File.expand_path('../../../lib/calendar_const', __FILE__)

module LoginHelper

def today_event
	d = Date.today
	date_s = "#{ApplicationHelper::PL_DAYS[d.cwday]}, #{d.day} #{ApplicationHelper::PL_MONTHS[d.month]}"
	if not (event = ApplicationHelper::Calendar_Polibuda[Time.now.strftime("%d-%m-%Y")]).nil?
		date_s += ", "+event
	else
		date_s += ", tydzień #{"nie" if d.cweek.odd?}parzysty"
	end
	date_s += ". "+event if not (event = ApplicationHelper::Calendar_Inne[Time.now.strftime("%d-%m-%Y")]).nil?
	return date_s
end

end

