reversed = function(anyList)
    if not anyList isa list then return null
    anyList = anyList[0:]
    i = 0
    j = anyList.len - 1
    while i < j
        tmp = anyList[i]
        anyList[i] = anyList[j]
        anyList[j] = tmp
        i = i + 1
        j = j - 1
    end while
    return anyList
end function

sorted = function(pokerNumberList, reverse = false) //length is fixed, only for sorting poker number.
    counts = [0] * 15
    for i in pokerNumberList
        counts[i] = counts[i] + 1
    end for
    ret = []
    i = 0
    while i < 15
        ret = ret + ([i] * counts[i])
        i = i + 1
    end while
    if reverse then return reversed(ret)
    return ret
end function

straight_rank = function(hand)
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    numbers = sorted(numbers, true)
    if numbers == [14, 5, 4, 3, 2] then return 7378945280
    last = numbers[0]
    for number in numbers[1:]
        if number != last - 1 then return 0
        last = last - 1
    end for
    return numbers[0] * (14 ^ 8)
end function

flush_rank = function(hand)
    suits = []
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
        suits.push(card[0])
    end for
    last = suits[0]
    for suit in suits[1:]
        if suit != last then return 0
    end for
    numbers = sorted(numbers, true)
    return numbers[0] * (14 ^ 9) + numbers[1] * (14 ^ 3) + numbers[2] * (14 ^ 2) + numbers[3] * 14 + numbers[4]
end function

straight_flush_rank = function(hand)
    if not straight_rank(hand) or not flush_rank(hand) then return 0
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    numbers = sorted(numbers, true)
    if numbers == [14, 5, 4, 3, 2] then return 283469561876480
    return numbers[0] * (14 ^ 12)
end function

four_rank = function(hand)
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    number_count = [0] * 15
    for number in numbers
        number_count[number] = number_count[number] + 1
    end for
    four_number = 0
    kicker = 0
    i = 0
    while i < 15
        if number_count[i] == 4 then four_number = i
        if number_count[i] == 1 then kicker = i
        i = i + 1
    end while
    if four_number == 0 or kicker == 0 then return 0
    return four_number * (14 ^ 11) + kicker
end function

full_rank = function(hand)
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    number_count = [0] * 15
    for number in numbers
        number_count[number] = number_count[number] + 1
    end for
    three_number = 0
    pair_number = 0
    i = 0
    while i < 15
        if number_count[i] == 3 then three_number = i
        if number_count[i] == 2 then pair_number = i
        i = i + 1
    end while
    if three_number == 0 or pair_number == 0 then return 0
    return three_number * (14 ^ 10) + pair_number
end function

three_rank = function(hand)
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    number_count = [0] * 15
    for number in numbers
        number_count[number] = number_count[number] + 1
    end for
    three_number = 0
    high_number = 0
    low_number = 0
    i = 0
    while i < 15
        if number_count[i] == 3 then three_number = i
        if number_count[i] == 1 then
            if low_number == 0 then
                low_number = i
            else
                high_number = i
            end if
        end if
        i = i + 1
    end while
    if low_number > high_number then
        tmp = low_number
        low_number = high_number
        high_number = tmp
    end if
    if three_number == 0 or high_number == 0 or low_number == 0 then return 0
    return three_number * (14 ^ 7) + high_number * 14 + low_number
end function

two_rank = function(hand)
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    number_count = [0] * 15
    for number in numbers
        number_count[number] = number_count[number] + 1
    end for
    high_pair = 0
    low_pair = 0
    kicker = 0
    i = 0
    while i < 15
        if number_count[i] == 2 then
            if low_pair == 0 then
                low_pair = i
            else
                high_pair = i
            end if
        end if
        if number_count[i] == 1 then kicker = i
        i = i + 1
    end while
    if low_pair > high_pair then
        tmp = low_pair
        low_pair = high_pair
        high_pair = tmp
    end if
    if high_pair == 0 or low_pair == 0 or kicker == 0 then return 0
    return high_pair * (14 ^ 6) + low_pair * 14 + kicker
end function

pair_rank = function(hand)
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    number_count = [0] * 15
    for number in numbers
        number_count[number] = number_count[number] + 1
    end for
    pair = 0
    kickers = []
    i = 0
    while i < 15
        if number_count[i] == 2 then pair = i
        if number_count[i] == 1 then kickers.push(i)
        i = i + 1
    end while
    if pair == 0 or kickers.len != 3 then return 0
    kickers = sorted(kickers, true)
    return pair * (14 ^ 5) + kickers[0] * (14 ^ 2) + kickers[1] * 14 + kickers[2]
end function

high_rank = function(hand)
    numbers = []
    for card in hand
        numbers.push(val(card[1:]))
    end for
    numbers = sorted(numbers, true)
    return numbers[0] * (14 ^ 4) + numbers[1] * (14 ^ 3) + numbers[2] * (14 ^ 2) + numbers[3] * 14 + numbers[4]
end function

"
a hand has a rank from royal flush to high card.
for high card, the hand value is in this equation, where first card is the biggest, last is the smallest, each has a number 2 to 14.
    rank = first * (14 ^ 4) + second * (14 ^ 3) + third * (14 ^ 2) + fourth * 14 + fifth
    for example, AQJT9 would be 14 * (14 ^ 4) + 12 * (14 ^ 3) + 11 * (14 ^ 2) + 10 * 14 + 9 = 573057
    such equation makes A3456(555327) to be higher than KJT98(531686), which is what we need.
for one pair, the hand value is in this equation
    rank = pair * (14 ^ 5) + third * (14 ^ 2) + fourth * 14 + fifth
    for example, AAKQJ would be 14 * (14 ^ 5) + 13 * (14 ^ 2) + 12 * 14 + 11 = 7532263
for two pair, the hand value is in this equation
    rank = high_pair * (14 ^ 6) + low_pair * 14 + fifth
    for example, AAKKQ would be 14 * (14 ^ 6) + 13 * 14 + 12 = 105413698
for three of a kind, the hand value is in this equation
    rank = three_of_a_kind * (14 ^ 7) + high * 14 + low
    for example, AAAKQ would be 14 * (14 ^ 7) + 13 * 14 + 12 = 1475789250
for straight, the hand value is in this equation
    rank = high * (14 ^ 8)
    special case where the straight is A2345, high is set to 5.
    for example, AKQJT would be 14 * (14 ^ 8) = 20661046784, A2345 would be 5 * (14 ^ 8) = 7378945280
for flush, the hand value is in this equation
    rank = first * (14 ^ 9) + second * (14 ^ 3) + third * (14 ^ 2) + fourth * 14 + fifth
    for example, AQJT9s would be 14 * (14 ^ 9) + 12 * (14 ^ 3) + 11 * (14 ^ 2) + 10 * 14 + 9 = 289254690209
for full house, the hand value is in this equation
    rank = three_of_a_kind * (14 ^ 10) + pair
    for example, AAAKK would be 14 * (14 ^ 10) + 13 = 4049565169677
for four of a kind, the hand value is in this equation
    rank = four_of_a_kind * (14 ^ 11) + fifth
    for example, AAAAK would be 14 * (14 ^ 11) + 13 = 56693912375309
for straight flush, the hand value is in this equation
    rank = high * (14 ^ 12)
    special case where the straight flush is A2345s, high is set to 5.
    for example, AKQJTs would be 14 * (14 ^ 12) = 793714773254144, A2345s would be 5 * (14 ^ 12) = 283469561876480
"
eval_hand = function(hand)
    if straight_flush_rank(hand) then return {"value": straight_flush_rank(hand), "rank": "straight flush"}
    if four_rank(hand) then return {"value": four_rank(hand), "rank": "four of a kind"}
    if full_rank(hand) then return {"value": full_rank(hand), "rank": "full house"}
    if flush_rank(hand) then return {"value": flush_rank(hand), "rank": "flush"}
    if straight_rank(hand) then return {"value": straight_rank(hand), "rank": "straight"}
    if three_rank(hand) then return {"value": three_rank(hand), "rank": "three of a kind"}
    if two_rank(hand) then return {"value": two_rank(hand), "rank": "two pair"}
    if pair_rank(hand) then return {"value": pair_rank(hand), "rank": "one pair"}
    return {"value": high_rank(hand), "rank": "high card"}
end function

Deck = function
    card = []
    for suit in "SHCD"
        for rank in range(2, 14)
            card.push(suit + rank)
        end for
    end for
    return card
end function

deck = Deck
for i in range(9)
    deck.shuffle
    hand = deck[:5]
    eval = eval_hand(hand)
    print(str(hand) + " " + str(eval.value) + " " + eval.rank)
end for