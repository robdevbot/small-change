class PaymentsController < ApplicationController

  def create
  end



  def process_all_payments
    Submission.all.each do |sub|
      process_payment(sub)
    end
  end

  def process_payment

    puts "looking for a submission with id #{params[:submission_id]}"

    sub = Submission.find(params[:submission_id])
    puts "found? #{sub}"
    puts "this submission is #{sub.id}, and it has #{sub.get_upvotes.size} upvotes"

    if sub.get_upvotes.size > sub.get_downvotes.size && sub.get_upvotes.size >=2
      puts "Processing submission ##{sub.id}, made by #{sub.recycler} on #{sub.created_at}"

      random_grant = Grant.find(rand(1..Grant.count))
      total = 0.00

      sub.submission_groups.each do |subm_group|
        total += (0.01 * subm_group.weight)
      end
      puts "About to create a payment with submission_id: #{sub.id}, grant_id: #{random_grant.id}, and amount: #{total}"

      payment = Payment.new(
        submission_id: sub.id,
        grant_id: random_grant.id,
        amount: total
        )

      # new_transaction = Braintree::Transaction.sale(
      # amount: params[:amount],
      # payment_method_nonce: params['client-nonce'],
      # options: {submit_for_settlement: true}
      # )


      if payment.save
        puts "Payment saved!"
      else
        puts "Payment not saved!"
        puts payment.errors.full_messages
      end

      random_grant.amount -= total
      random_grant.save
      puts "Grant reduced to #{random_grant.amount}."
      puts "Changing the status on the original submission"
      sub.status = "Paid"
      sub.save
    else # end of if sub.votes
      puts "Error: not enough votes or vote count too low."
      sub.status = "Rejected"
    end # end of if sub.votes
  end #end of process_payment
end #end of class
