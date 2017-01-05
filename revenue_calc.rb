require 'open-uri'
require 'json'
require 'bigdecimal'

class RevenueCalculator
  # initialize calculator with resource address and security token
  def initialize(token, base_url)
    @access_token = token
    @orders_base = base_url
  end

  # fetch all orders with specified fields, default fields are ID, total price(original currency and USD), transaction status, total tax and currency
  def orders(fields='id,total_price,financial_status,currency,total_tax,total_price_usd')
    orders, page = [], 1
    loop do
      payload = open("#{@orders_base}.json?fields=#{fields}&page=#{page}&access_token=#{@access_token}") { |f| f.read }
      page += 1
      orders << JSON.parse(payload)['orders']
      orders.flatten!
      break if orders.size == count_orders
    end
    orders
  end

  # count all available orders
  def count_orders
    JSON.parse(open("#{@orders_base}/count.json?access_token=#{@access_token}").readline)['count']
  end

  # return a hash of type {:currency_code => [a, list, of, orders]}
  def orders_by_currency
    orders_by_currency = init_hash(Array.new)
    currencies.each{ |code| orders_by_currency[code] }
    orders.each do |order|
      orders_by_currency[order['currency']] << order
    end
    orders_by_currency
  end

  # return a hash of type {:currency_code => {total_price: value, total_tax: value}}
  def revenue_by_currency
    balance = init_hash(Hash.new)
    currencies.each{ |code| balance[code] }
    orders_by_currency.each do |currency, orders|
      balance[currency] = {
          total_price: orders.inject(0){ |total, subtotal| total + BigDecimal.new(subtotal['total_price'])},
          total_tax: orders.inject(0){ |total, subtotal| total + BigDecimal.new(subtotal['total_tax'])},
      }
    end
    balance
  end

  def revenue_usd
    orders.inject(0){ |total, subtotal| total + BigDecimal.new(subtotal['total_price_usd']) }
  end

  private

  # initialize a hash with currency codes as keys
  def init_hash(value)
    Hash.new do |hash, key|
      hash[key] = value
    end
  end

  # return all available currency codes
  def currencies
    orders.map{ |order| order['currency'] }.uniq
  end

end

token = 'c32313df0d0ef512ca64d5b336a0d7c6'
url = 'https://shopicruit.myshopify.com/admin/orders'

calc = RevenueCalculator.new token, url

calc.revenue_by_currency.each do |currency, hash|
  puts currency
  puts "  Subtotal: #{(hash[:total_price] + hash[:total_tax]).to_s('F')}"
  puts "  Tax: #{hash[:total_tax].to_s('F')}"
  puts "  Total: #{hash[:total_price].to_s('F')}"
end

puts "Total revenue is #{calc.revenue_usd.to_s('F')}$"
