module ShopifyAPI
  class AssignedFulfillmentOrder < Base
    CANCELLATION_REQUESTED = 'cancellation_requested'
    FULFILLMENT_REQUESTED = 'fulfillment_requested'
    FULFILLMENT_ACCEPTED = 'fulfillment_accepted'

    ALL_ASSIGNED_STATUSES = [
      CANCELLATION_REQUESTED = 'cancellation_requested',
      FULFILLMENT_REQUESTED = 'fulfillment_requested',
      FULFILLMENT_ACCEPTED = 'fulfillment_accepted'
    ].freeze

    def self.all(options = {})
      params = options[:params] || options['params'] || {}
      assigned_status = params[:assigned_status] || params['assigned_status']
      if assigned_status && !ALL_ASSIGNED_STATUSES.include?(assigned_status)
        raise ValidationException, "Invalid 'assigned_status': #{assigned_status}"
      end

      assigned_fulfillment_orders = super(options)
      assigned_fulfillment_orders.map { |afo| FulfillmentOrder.new(afo.as_json) }
    end
  end
end
