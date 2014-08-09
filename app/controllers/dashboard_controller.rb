class DashboardController < ApplicationController

  def index
    @pdns_pid = `pidof pdns_server`.chop
    records = @current_user.admin ? Record : @current_user.records
    @records = records.order(:change_date).reverse_order.limit(10)
  end
end
