class DashboardController < ApplicationController

  def index
    @pdns_pid = `pidof pdns_server`.chop
    records = @current_user.admin ? Record : @current_user.records
    @records = {records: records.last_changed(10)}
  end

end
