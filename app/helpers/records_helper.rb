module RecordsHelper

  def sane_ttl ttl
    case ttl = ttl.to_i
    when 0...2.minutes
      "#{ ttl }s"
    when 2.minutes...120.minutes
      "#{ ttl / 1.minute }min"
    when 120.minutes...2.days
      "#{ ttl / 1.hour }h"
    when 2.days...2.month
      "#{ ttl / 1.day }d"
    else
      "#{ ttl / 1.month }mo"
    end
  end

  def soa_times s_soa
    return s_soa unless s_soa.respond_to? :split
    return s_soa unless (a_soa = s_soa.split).count == 7
    a_new = a_soa.first(3) + a_soa.last(4).map {|t| sane_ttl t }
    a_new.join(' ')
  end
end
