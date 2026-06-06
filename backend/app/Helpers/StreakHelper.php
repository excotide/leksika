<?php

namespace App\Helpers;

use App\Models\UserStreak;
use Carbon\Carbon;

class StreakHelper
{
  public function updateStreak($userId)
  {
    $today = Carbon::today();
    $yesterday = Carbon::yesterday();

    $streak = UserStreak::firstOrCreate(
      ['user_id' => $userId],
      ['current_streak' => 0, 'max_streak' => 0, 'last_activity_date' => null]
    );

    $lastActivity = $streak->last_activity_date ? Carbon::parse($streak->last_activity_date)->startOfDay() : null;

    if ($lastActivity) {
      if ($lastActivity->equalTo($today)) {
        return $streak;
      } elseif ($lastActivity->equalTo($yesterday)) {
        $streak->current_streak += 1;
      } else {
        $streak->current_streak = 1;
      }
    } else {
      $streak->current_streak = 1;
    }

    if ($streak->current_streak > $streak->max_streak) {
      $streak->max_streak = $streak->current_streak;
    }

    $streak->last_activity_date = $today;
    $streak->save();

    return $streak;
  }

  public function getStreakForDisplay($userId)
  {
    $streak = UserStreak::firstOrCreate(
      ['user_id' => $userId],
      ['current_streak' => 0, 'max_streak' => 0, 'last_activity_date' => null]
    );

    if ($streak->last_activity_date) {
      $today = Carbon::today();
      $yesterday = Carbon::yesterday();
      $lastActivity = Carbon::parse($streak->last_activity_date)->startOfDay();

      if (!$lastActivity->equalTo($today) && !$lastActivity->equalTo($yesterday)) {
        $streak->current_streak = 0;
        $streak->save();
      }
    }

    return $streak;
  }
}
