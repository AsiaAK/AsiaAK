/**
 * Created by pavel on 4/10/2018.
 */

public with sharing class GeocodeResult {
    public Id sfid { get; set; }
    public Decimal latitude { get; set; }
    public Decimal longitude { get; set; }
}