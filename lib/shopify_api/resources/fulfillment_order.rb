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
      body = { fulfillment_order: { new_location_id: new_location_id } }.to_json
      keyed_fulfillment_orders = keyed_fulfillment_orders_from_response(post(:move, {}, body))
      load_keyed_fulfillment_order(keyed_fulfillment_orders, 'original_fulfillment_order')
      keyed_fulfillment_orders
    end

    def cancel
      keyed_fulfillment_orders = keyed_fulfillment_orders_from_response(post(:cancel, {}, only_id))
      load_keyed_fulfillment_order(keyed_fulfillment_orders, 'fulfillment_order')
      keyed_fulfillment_orders
    end

    def close
      load_attributes_from_response(post(:close, {}, only_id))
    end

    def request_fulfillment(fulfillment_order_line_items:, message: nil)
      body = {
        fulfillment_request: {
          fulfillment_order_line_items: fulfillment_order_line_items,
          message: message
        }
      }
      keyed_fulfillment_orders = keyed_fulfillment_orders_from_response(post(:fulfillment_request, {}, body.to_json))
      load_keyed_fulfillment_order(keyed_fulfillment_orders, 'original_fulfillment_order')
      keyed_fulfillment_orders
    end

    def accept_fulfillment_request(message: nil)
      body = { message: message }
      load_attributes_from_response(post('fulfillment_request/accept', {}, body.to_json))
    end

    def reject_fulfillment_request(message: nil)
      body = { message: message }
      load_attributes_from_response(post('fulfillment_request/reject', {}, body.to_json))
    end

    def request_cancellation(message: nil)
      body = {
        cancellation_request: {
          message: message
        }
      }
      load_attributes_from_response(post(:cancellation_request, {}, body.to_json))
    end

    def accept_cancellation_request(message: nil)
      body = { message: message }
      load_attributes_from_response(post('cancellation_request/accept', {}, body.to_json))
    end

    def reject_cancellation_request(message: nil)
      body = { message: message }
      load_attributes_from_response(post('cancellation_request/reject', {}, body.to_json))
    end

    private

    def load_keyed_fulfillment_order(keyed_fulfillment_orders, key)
      if keyed_fulfillment_orders[key]&.attributes
        load(keyed_fulfillment_orders[key].attributes, false, true)
      end
    end

    def keyed_fulfillment_orders_from_response(response)
      return load_attributes_from_response(response) if response.code != '200'

      keyed_fulfillment_orders = ActiveSupport::JSON.decode(response.body)
      keyed_fulfillment_orders.transform_values do |fulfillment_order_attributes|
        FulfillmentOrder.new(fulfillment_order_attributes) if fulfillment_order_attributes
      end
    end
  end
end
