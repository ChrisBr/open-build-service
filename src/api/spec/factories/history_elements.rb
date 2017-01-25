FactoryGirl.define do
  factory :history_element_review_assigned, class: 'HistoryElement::ReviewAssigned' do
    type { 'HistoryElement::ReviewAssigned' }
  end

  factory :history_element_review_accepted, class: 'HistoryElement::ReviewAccepted' do
    type { 'HistoryElement::ReviewAccepted' }
  end

  factory :history_element_request_created, class: 'HistoryElement::RequestCreated' do
    type { 'HistoryElement::RequestCreated' }
  end

  factory :history_element_request_accepted, class: 'HistoryElement::RequestAccepted' do
    type { 'HistoryElement::RequestAccepted' }
  end
end
