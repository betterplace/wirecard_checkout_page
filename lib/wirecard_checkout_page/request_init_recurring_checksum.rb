require 'wirecard_checkout_page/value_handling'

module WirecardCheckoutPage
  class RequestInitRecurringChecksum
    include WirecardCheckoutPage::Utils
    include WirecardCheckoutPage::ValueHandling

    FINGERPRINT_KEYS = %w[
      secret
      customerId
      amount
      shopId
      paymentType
      currency
      language
      orderDescription
      transactionIdentifier
      serviceURL
      successURL
      cancelURL
      failureURL
      confirmURL
      orderReference
      requestFingerprintOrder
    ].freeze

    def initialize(values = {})
      @values = stringify_keys(values)
      @fingerprint_keys = @values.delete('fingerprint_keys') || FINGERPRINT_KEYS
      @secret = @values.delete('secret') or
        raise WirecardCheckoutPage::ValueMissing, 'value "secret" is missing'
      @values = add_some_defaults @values
      @values.freeze
      @secret = @secret
      reset_missing_keys
    end

    attr_reader :fingerprint_keys

    attr_reader :values

    def request_parameters
      reset_missing_keys
      parameters = @values.dup
      parameters['requestFingerprintOrder'] = requestFingerprintOrder
      parameters['requestFingerprint'] = fingerprint
      if missing_keys?
        raise WirecardCheckoutPage::ValueMissing,
          "values #{missing_keys * ', ' } are missing"
      end
      parameters
    end

    private

    def fingerprint
      values = @values.dup
      values.update(
        'requestFingerprintOrder' => requestFingerprintOrder,
        'secret'                  => @secret,
      )
      Digest::MD5.hexdigest requestFingerprintSeed(values)
    end

    def requestFingerprintSeed(values)
      seed = fingerprint_keys.map { |k|
        values.fetch(k) do
          add_missing_key k
          next
        end
      } * ''
    end

    def requestFingerprintOrder
      @requestFingerprintOrder ||= fingerprint_keys.join(',').freeze
    end

    def add_some_defaults(values)
      default_values = {
        'shopId'      => 'betterplace', # Missing!?!?
        'paymentType' => 'SELECT',
        'currency'    => 'EUR',
        'language'    => 'de',
        'transactionIdentifier' => 'INITIAL',
      }
      values.update(default_values) do |key,old,new|
        old.nil? ? new : old
      end
    end
  end
end
