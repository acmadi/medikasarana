{* Extend our master template *}
{extends file="../../../master.tpl"}
{block name=content}

    <!-- New invoice template -->
    <div class="panel panel-success">
        <div class="panel-heading">
            <h6 class="panel-title"><i class="icon-checkmark3"></i> Retur Invoice</h6>

            <div class="dropdown pull-right">
                <a href="#" class="dropdown-toggle panel-icon" data-toggle="dropdown">
                    <i class="icon-cog3"></i>
                    <b class="caret"></b>
                </a>
            </div>
        </div>

        <div class="panel-body">

            <div class="row invoice-header">
                <div class="col-sm-6">
                    <h3>{$master->store_name}</h3>
                    <span>{$master->address} - {$master->zipcode}
                        </br>
                        {$master->city} - {$master->state}
                        </br>
                        {$master->telp1} - {$master->telp2}
                    </span>
                </div>

                <div class="col-sm-3 pull-right">
                    <ul>
                        <li>No Faktur Retur# <strong class="text-danger pull-right">{$master->id_retail_return}</strong>
                        </li>
                        <li>No Faktur Retail# <strong class="text-danger pull-right">{$master->id_retail}</strong></li>
                        <li>Staff <strong class="pull-right">{$master->staff_name} </strong></li>
                        <li>Date : <strong class="pull-right">{$master->date}</strong></li>
                    </ul>
                </div>
            </div>


            <div class="table-responsive">
                <table class="table table-striped table-bordered">
                   <thead>
                    <tr>
                        <th>No</th>
                        <th>Barcode</th>
                        <th>Nama Produk</th>
                        <th>Merek</th>
                        <th>Satuan / Isi</th>
                        <th>Jumlah</th>
                        <th>Kembali</th>
                        <th>Keterangan</th>
                    </tr>
                    </thead>
                    <tbody>
                    {assign var=no value=1}
                    {assign var=total_cashback value=0}
                    {foreach $items as $return }
                        {assign var=total_cashback value=$total_cashback+$return['cashback']}
                        <tr>
                            <td rowspan="2">{$no} </td>
                            <td>{$return['barcode']}</td>
                            <td>{$return['name']}</td>
                            <td>{$return['brand']}</td>
                            <td style="width:100px;">{$return['unit']} ( {$return['value']} )</td>
                            <td>{$return['qty_return']}</td>
                            <td></td>
                            <td rowspan="2">{$return['reason']}</td>
                        </tr>

                        <tr>
                            {if $return['id_product_cache']}
                                <td>{$product_storage[$return['id_product_cache']]['barcode']}</td>
                                <td>{$product_storage[$return['id_product_cache']]['name']}</td>
                                <td>{$product_storage[$return['id_product_cache']]['brand']}</td>
                                <td>
                                    {$product_storage[$return['id_product_cache']]['unit']}
                                    ( {$product_storage[$return['id_product_cache']]['value']} )
                                    </td>
                                <td>{$return['qty']}</td>
                            {else}
                                <td colspan="5"></td>
                            {/if}
                            <td>Rp
                                {if $return['cashback']}
                                    {$return['cashback']|number_format:0}
                                {else}
                                    {0|number_format:0}
                                {/if}
                            </td>
                        </tr>
                        {assign var=no value=$no+1}
                    {/foreach}
                    </tbody>
                </table>
            </div>
            
            <div class="row invoice-payment">
                <div class="col-sm-8">
                </div>

                <div class="col-sm-4">
                    <table class="table">
                        <tbody>
                            <tr>
                                <th>Total:</th>
                                <td class="text-right">Rp {$total_cashback|number_format:0}</td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="btn-group pull-right">
                        <a href="{base_url('retail')}" class="btn btn-info button">
                            <i class="icon-box-add"></i> New Retail</a>
                        <button type="button" class="btn btn-primary" onclick="print_doc();" id="button-focus">
                            <i class="icon-print2"></i> Print</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- /new invoice template -->
{/block}
{block name=print}
    <div id="print">
        <font size="2em">
            <table border="0" width="100%">
                <tr>
                    <td width="40%" align="left" valign="top">
                        {$master->store_name}
                        </br>
                        {$master->address} - {$master->zipcode}
                        </br>
                        {$master->city} - {$master->state}
                        </br>
                        {$master->telp1} - {$master->telp2}
                        </br>
                        NPWP : {$master->npwp}
                    </td>
                    <td width="40%" align="left" valign="top">
                    </td>
                    <td>
                        #{$master->id_retail_return} / #{$master->id_retail} / {$master->staff_name} /
                        </br>
                        {$master->date}
                    </td>
                </tr>
            </table>
        </font>
        </br>
        <font size="2em">
            <table border="0" width="100%">
                <thead style="border-top: 1px dashed; border-bottom: 1px dashed;">
                <tr>
                    <th>No</th>
                    <th min-width="40%">Nama Produk</th>
                    <th>Merek</th>
                    <th>Satuan / Isi</th>
                    <th>Jumlah</th>
                    <th>Kembali</th>
                    <th>Keterangan</th>
                </tr>
                </thead>
                <tbody class="tbody-a5">
                {assign var=no value=1}
                    {assign var=total_cashback value=0}
                    {foreach $items as $return }
                        {assign var=total_cashback value=$total_cashback+$return['cashback']}
                        <tr>
                            <td rowspan="2">{$no} </td>
                            <td>{$return['name']}</td>
                            <td>{$return['brand']}</td>
                            <td style="width:100px;">{$return['unit']} ( {$return['value']} )</td>
                            <td>{$return['qty_return']}</td>
                            <td></td>
                            <td rowspan="2">{$return['reason']}</td>
                        </tr>
                        <tr>
                            {if $return['id_product_cache']}
                                <td>{$product_storage[$return['id_product_cache']]['name']}</td>
                                <td>{$product_storage[$return['id_product_cache']]['brand']}</td>
                                <td>
                                    {$product_storage[$return['id_product_cache']]['unit']}
                                    ( {$product_storage[$return['id_product_cache']]['value']} )
                                    </td>
                                <td>{$return['qty']}</td>
                            {else}
                                <td colspan="4"></td>
                            {/if}
                            <td>Rp
                                {if $return['cashback']}
                                    {$return['cashback']|number_format:0}
                                {else}
                                    {0|number_format:0}
                                {/if}
                            </td>
                        </tr>
                        {assign var=no value=$no+1}
                    {/foreach}
                </tbody>
            </table>
            </br>
            <table border="0" width="100%">
                <tr>
                    <td width="100%" align="center" valign="top">
                        Total Kembali : Rp {$total_cashback|number_format:0} 
                    </td>
                </tr>
                <tr>
                    <td width="100%" align="center" valign="top">
                        <span>
                            TERIMA KASIH DAN SELAMAT BELANJA KEMBALI
                        </span>
                    </td>
                </tr>
            </table>
        </font>
    </div>
{/block}


