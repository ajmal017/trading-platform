require 'test/unit'

class TestMarketTime < Test::Unit::TestCase
  def test_0900
   assert !validate(9, 0)
  end

  def test_0930
   assert !validate(9, 30)
  end

  def test_0931
   assert !validate(9, 31)
  end

  def test_0959
   assert !validate(9, 59)
  end

  def test_1000
   assert validate(10, 0)
  end

  def test_1029
   assert validate(10, 29)
  end

  def test_1100
   assert validate(11, 0)
  end

  def test_1131
   assert validate(11, 31)
  end

  def test_1200
   assert validate(12, 0)
  end

  def test_1230
   assert validate(12, 30)
  end

  def test_1231
   assert !validate(12, 31)
  end

  def test_1300
   assert !validate(13, 0)
  end

  def test_1350
   assert !validate(13, 50)
  end

  def test_1400
   assert !validate(14, 0)
  end

  def test_1429
   assert !validate(14, 29)
  end

  def test_1430
   assert validate(14, 30)
  end

  def test_1459
   assert validate(14, 59)
  end

  def test_1500
   assert validate(15, 0)
  end

  def test_1531
   assert validate(15, 31)
  end

  def test_1600
   assert validate(16, 0)
  end

  def test_1630
   assert validate(16, 30)
  end

  def test_1631
   assert !validate(16, 31)
  end

  def test_1700
   assert !validate(17, 0)
  end

  def validate(hour, min)
    if hour == 10 || hour == 11 || (hour == 12 && min <= 30) ||
       (hour == 14 && min >= 30) || hour == 15 || (hour == 16 && min <= 30)
      return true
    end
    false
  end
end
