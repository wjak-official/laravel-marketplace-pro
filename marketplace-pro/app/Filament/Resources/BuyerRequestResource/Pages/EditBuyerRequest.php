<?php

namespace App\Filament\Resources\BuyerRequestResource\Pages;

use App\Filament\Resources\BuyerRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditBuyerRequest extends EditRecord
{
    protected static string $resource = BuyerRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
