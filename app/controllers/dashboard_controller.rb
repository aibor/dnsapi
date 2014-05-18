class DashboardController < ApplicationController
  def index
    @pdns_pid = `pidof pdns_server`.chop
    @records = Record.order(:change_date).reverse_order.limit(10)
  end
end
