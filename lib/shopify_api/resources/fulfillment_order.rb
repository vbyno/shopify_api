module ShopifyAPI
  class FulfillmentOrder < Base
    def self.all(options = {})
      order_id = options.dig(:params, :order_id)
      raise ShopifyAPI::ValidationException, "'order_id' is required" if order_id.nil? || order_id == ''

      order = ::ShopifyAPI::Order.new(id: order_id)
      order.fulfillment_orders
    end

    def fulfillments(options = {})
      fulfillments = get(:fulfillments, options)
      fulfillments.map { |fulfillment| FulfillmentV2.new(fulfillment.as_json) }
    end

    def move(new_location_id:)
      body = { fulfillment_order: { new_location_id: new_location_id } }
      load_values(post(:move, body, only_id))
    end

    def cancel
      load_values(post(:cancel, {}, only_id))
    end

    def close
      load_attributes_from_response(post(:close, {}, only_id))
    end

    private

    def load_values(response)
      return load_attributes_from_response(response) if response.code != '200'

      keyed_fulfillments = ActiveSupport::JSON.decode(response.body)
      keyed_fulfillments.map do |key, fo_attributes|
        if fo_attributes.nil?
          [key, nil]
        else
          [key, FulfillmentOrder.new(fo_attributes)]
        end
      end.to_h
    end
  end
end
