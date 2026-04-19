<?php

namespace App\Filament\Resources\BuyerRequestResource\Pages;

use App\Filament\Resources\BuyerRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListBuyerRequests extends ListRecords
{
    protected static string $resource = BuyerRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
