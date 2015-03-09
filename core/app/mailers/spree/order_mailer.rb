module Spree
  class OrderMailer < BaseMailer
    def confirm_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Store.current.name} #{Spree.t('order_mailer.confirm_email.subject')} ##{@order.number}"
      
      if !@order.invoice_number.present?
        @order.invoice_number = Spree::PrintInvoice::Config.increase_invoice_number
        @order.invoice_date = Date.today
        @order.save!
      end
      
      filename = "Invoice.pdf"
      if @order.invoice_number.present?
        filename = "Invoice_#{@order.invoice_number}_#{@order.number}.pdf"
      else
        filename = "Invoice_#{@order.number}.pdf"
      end
      
      admin_controller = Spree::Admin::OrdersController.new
      invoice = admin_controller.render_to_string(:layout => false , :template => "spree/admin/orders/invoice.pdf.prawn", :type => :prawn, :locals => {:@order => @order})

      attachments[filename] = {
        mime_type: 'application/pdf',
        content: invoice
      }
      
      mail(to: @order.email, from: from_address, subject: subject)
    end

    def cancel_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Store.current.name} #{Spree.t('order_mailer.cancel_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end
  end
end
