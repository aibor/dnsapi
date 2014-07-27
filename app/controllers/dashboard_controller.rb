class DashboardController < ApplicationController

  def index
    @pdns_pid = `pidof pdns_server`.chop
    @records = (@user.admin ? Record : @user.records).order(:change_date).reverse_order.limit(10)
  end
end
