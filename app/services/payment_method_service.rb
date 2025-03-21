class PaymentMethodService
  def default_payment_method
    PaymentMethod.find_or_create_by(name: 'Efectivo') do |payment_method|
      payment_method.description = 'Pago en efectivo'
      payment_method.active = true
    end
  end
end
