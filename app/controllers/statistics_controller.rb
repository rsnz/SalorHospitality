class StatisticsController < ApplicationController
  def index
  end

  def tables
    @from, @to = assign_from_to(params)
    @tables = Table.find(:all)
  end

  def weekdays
    @from, @to = assign_from_to(params)
    @weekdaysums = []
    0.upto 6 do |day|
      @weekdaysums[day] = Order.sum( 'sum', :conditions => "WEEKDAY(created_at)=#{day}" )
    end
  end

  def users
    @from, @to = assign_from_to(params)
    @users = User.find(:all)
  end

  def articles
    #This is really an statistic of Item instead of Article, but this naming is more intuitive.
    @from, @to = assign_from_to(params)
    @articlesums = {}
    @quantitysums = {}
    articleIDs = Item.find(:all, :conditions => { :created_at => @from..@to }).map{|record| record.article_id }.uniq
    quantityIDs = Item.find(:all, :conditions => { :created_at => @from..@to }).map{|record| record.quantity_id }.uniq
    articleIDs.each do |id|
      next if id.nil?
      @articlesums[id] = Item.sum( 'count', :conditions => "article_id = #{id}" )
    end
    quantityIDs.each do |id|
      next if id.nil?
      @quantitysums[id] = Item.sum( 'count', :conditions => "quantity_id = #{id}" )
    end
    @articlesums = @articlesums.sort {|a,b| b[1]<=>a[1]}
    @quantitysums = @quantitysums.sort {|a,b| b[1]<=>a[1]}
  end

  def journal
    @from, @to = assign_from_to(params)
    if not params[:cost_center_id] or params[:cost_center_id].empty?
      @orders = Order.find(:all, :conditions => { :created_at => @from..@to })
    else
      @orders = Order.find(:all, :conditions => { :created_at => @from..@to, :cost_center_id => params[:cost_center_id] })
    end
    @cost_centers = CostCenter.all
    render '/statistics/journal.csv' if params[:commit] == 'file'
  end

  private

    def assign_from_to(p)
      f = Date.civil( p[:from][:year ].to_i,
                      p[:from][:month].to_i,
                      p[:from][:day  ].to_i) if p[:from]
      t = Date.civil( p[:to  ][:year ].to_i,
                      p[:to  ][:month].to_i,
                      p[:to  ][:day  ].to_i) if p[:to]
      f ||= 1.day.ago
      t ||= 0.day.ago

      return f, t
    end

end
