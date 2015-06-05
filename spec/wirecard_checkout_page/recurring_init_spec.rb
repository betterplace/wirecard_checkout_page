require 'spec_helper'

describe WirecardCheckoutPage::Gateway do
  fail 'Missing ENV[CUSTOMER_ID], e.g. D21000xx' unless !!ENV['CUSTOMER_ID']
  fail 'Missing ENV[SECRET], E.g. AJHASKAJ***KAJW' unless !!ENV['SECRET']

  let(:gateway) { WirecardCheckoutPage::Gateway.new(customerId: ENV['CUSTOMER_ID'], secret: ENV['SECRET'])}
  let(:valid_params) do
    {
      amount:           '100.00',
      orderDescription: 'order',
      serviceURL:       'https://bp42.com',
      successURL:       'https://bp42.com',
      cancelURL:        'https://bp42.com',
      failureURL:       'https://bp42.com',
      confirmURL:       'https://bp42.com',
      orderReference:   '123',
    }
  end

  it 'works' do
    response = gateway.init_recurring(valid_params)
  end
end
