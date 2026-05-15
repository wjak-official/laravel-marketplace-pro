<?php

namespace App\Filament\Resources\MatchRecordResource\Pages;

use App\Filament\Resources\MatchRecordResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditMatchRecord extends EditRecord
{
    protected static string $resource = MatchRecordResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
